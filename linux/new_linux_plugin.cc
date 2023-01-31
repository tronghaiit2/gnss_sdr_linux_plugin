#include "include/new_linux_plugin/new_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <string.h>

#include <thread>
#include <chrono>
#include <sstream>
#include <iostream>
#include <vector>
#include <map>
#include <cmath>
#include <numeric>

#include "safe_queue.h"

SharedQueue<std::map<int, double>> S4_T;
int countSI = 0, prn = 0, errorCount = 0;
bool flag = true;
bool over60s = false;
double SI_mean, SI_mean_2, SI_2_mean, S4_T_index;
double listSiRaw1s[33] = {0};
std::vector<double> siRaw60s[33] = {std::vector<double>(0)};
// std::vector<double> si60s[33] = {std::vector<double>(0)};
double siTrend60s = 0;
std::map<int, float> listData;
std::map<int, float> listCN0;
// std::map<int, double> S4_T_pair;
// std::map<int, double> listSIRaw;


#define NEW_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), new_linux_plugin_get_type(), \
                              NewLinuxPlugin))

#define PERMS 0644
struct my_msgbuf {
   long mtype;
   char mtext[256];
};

struct _NewLinuxPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(NewLinuxPlugin, new_linux_plugin, g_object_get_type())

struct my_msgbuf buf;
int msqid = -1;
int toend;
key_t key;

double average(std::vector<double> const& v) {
    if (v.empty()) {
        return 0;
    }
    return std::accumulate(v.begin(), v.end(), 0.0) / v.size();
}

double getAverage(std::vector<double> const& v) {
    if (v.empty()) {
        return 0;
    }
 
    double sum = 0.0;
    int count = 0;
    for (const double i: v) {
        if(i != 0) {
          sum += i;
          count += 1;
        }
    }
    if(count == 0) return 0;
    return sum / count;
}

void calculateS4() {
  // Insert element = 0 in listSIRaw if ri_raw exists
  if(siRaw60s[0].size() > 60) over60s = true;

  for(int i = 1; i < 33; i++) {
    // printf("listSiRaw1s[%d]: %lf\n", i, listSiRaw1s[i]);
    siRaw60s[i].push_back(listSiRaw1s[i]);
    if(over60s) {
      siRaw60s[i].erase(siRaw60s[i].begin());
    }
  }
  if(over60s) {
    siRaw60s[0].erase(siRaw60s[0].begin());
    over60s = false;
  }

  std::map<int, double> S4_T_pair;
  // S4_T_pair.clear();
  std::vector<double> si60s[33] = {std::vector<double>(0)};
  // si60s->clear();
  for(int i = 1; i < 33; i++) {
    if (siRaw60s[i].size() > 0) {
      siTrend60s = getAverage(siRaw60s[i]);
      // printf("prn: %d siTrend60s: %lf\n", i, siTrend60s);
      for (const double siRaw: siRaw60s[i]) {
        if(siTrend60s != 0) {
          si60s[i].push_back(siRaw/siTrend60s);
        }
        else {
          si60s[i].push_back(0);
        }
      }
      
      countSI = 0;
      SI_mean = 0;
      SI_2_mean = 0.0;
      if(siTrend60s != 0.0) {
        for (const double si: si60s[i]) {
          // printf("prn: %d si: %lf\n", i, si);
          if(si != 0) {
            SI_2_mean += si*si;
            SI_mean += si;
            countSI++;
          }
          else {
            SI_2_mean += 0;
          }
        }
        if(countSI > 0) {
          SI_mean = SI_mean / countSI;
          SI_mean_2 = SI_mean*SI_mean;
          SI_2_mean = SI_2_mean / countSI;
          S4_T_index = sqrt((SI_2_mean - SI_mean_2)/ SI_mean_2);
          // printf("prn: %d S4_T_index: %lf\n", i, S4_T_index);
          S4_T_pair.insert(std::make_pair(i, S4_T_index));
        }
      }
    }
  }

  while(S4_T.size() > 0) {
    S4_T.pop_front();
  }
  S4_T.push_back(S4_T_pair);
}

void receiveData() {
  std::map<int, float> list_Data;
  std::map<int, float> list_CN0;
  std::vector<double> list_SIRaw[33] = {std::vector<double>(0)};

  long diff;
  std::chrono::time_point<std::chrono::system_clock> start, end;
  start = std::chrono::system_clock::now();
  for(;;) {
    // list_Data.clear();
    // list_CN0.clear();
    // list_SIRaw->clear();
    // data_list.clear();

    end = std::chrono::system_clock::now();
    diff = std::chrono::duration_cast< std::chrono::milliseconds >(
      end.time_since_epoch() - start.time_since_epoch()).count();
    if(diff > 900) {
      break;
    }
    ssize_t siz = msgrcv(msqid, &buf, sizeof(buf.mtext), 0, IPC_NOWAIT);
    if (siz<0) {
      if (errno == ENOMSG) 
        {
          if(diff > 850 && list_CN0.empty()) {
            errorCount++;
            if(errorCount > 5) {
              toend = 0;
              break;
            }
          }
        }
      else {
        toend = 0;
        perror("msgrcv");
        break;
      }
    } 
    else {
      errorCount = 0;
      std::vector<double> data_list;
      std::stringstream ss;
      ss << buf.mtext;
      while(!ss.eof()){
          std::string x;
          ss >> x;
          double y = atof(x.c_str());
          if(y != 0) data_list.push_back(y);
      }
      // printf("recvd: %lf: %.5lf\n", data_list[0], data_list[2]);
      // list_Data.insert(std::make_pair(data_list[0], data_list[2]));
      prn = (int)data_list[0];
      list_CN0.insert(std::make_pair(prn, data_list[1]));

      // Insert list SIRaw
      if(data_list.size() > 2) {
        list_SIRaw[prn].push_back(data_list[2]);

      }
      toend = strcmp(buf.mtext,"end");
      if (toend == 0 || sizeof(buf.mtext) == 0) 
      break;
    } 
  }

  listCN0 = list_CN0;
  for(int i = 0; i < 33; i++){
    // printf("list_SIRaw: %lf\n", data_list[2]);
    listSiRaw1s[i] = average(list_SIRaw[i]);
  }

  calculateS4();
  end = std::chrono::system_clock::now();
  diff = std::chrono::duration_cast< std::chrono::milliseconds >(
    end.time_since_epoch() - start.time_since_epoch()).count();
  printf("diff: %ld\n", diff);

  if(toend == 0) {
    // listSiRaw1s = {0};
    siRaw60s->clear();
    // si60s->clear();
    return;
  }
}

// Called when a method call is received from Flutter.
static void new_linux_plugin_handle_method_call(
    NewLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "receiveData") == 0) {
      if(toend == 0 && listData.empty()) {
        g_autofree gchar *data = g_strdup_printf("%s", "end");
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
      else {
        int ELEMENTSIZE = 32;
        int BUFSIZE = listData.size()*ELEMENTSIZE;
        char dataSent[BUFSIZE];
        strcpy(dataSent, "");
        strcat(dataSent, "{");
        // strcat(dataSent, "[{\"ID\":0}");
        for(auto it = listData.cbegin(); it != listData.cend(); ++it)
        {
            // std::cout << it->first << " " << it->second<< "\n";
            char *str = (char*) malloc(sizeof(char) * ELEMENTSIZE);
            snprintf(str, ELEMENTSIZE, "\"%d\":%.5f,", it->first, it->second);
            strcat(dataSent, str);
            free(str);
        }
        // strcat(dataSent, "]");
        dataSent[strlen(dataSent) - 1] = '}';
              
        // printf("%s\n", dataSent);
        g_autofree gchar *data = g_strdup_printf("%s", dataSent);
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
  }
  else if (strcmp(method, "receiveCN0") == 0) {
      if(toend == 0 && listCN0.empty()) {
        g_autofree gchar *data = g_strdup_printf("%s", "end");
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
      else {
        int ELEMENTSIZE = 20;
        int BUFSIZE = listCN0.size()*ELEMENTSIZE;
        char dataSent[BUFSIZE];
        strcpy(dataSent, "");
        strcat(dataSent, "{");
        // strcat(dataSent, "[{\"ID\":0}");
        for(auto it = listCN0.cbegin(); it != listCN0.cend(); ++it)
        {
            // std::cout << it->first << " " << it->second<< "\n";
            char *str = (char*) malloc(sizeof(char) * ELEMENTSIZE);
            snprintf(str, ELEMENTSIZE, "\"%d\":%.5f,", it->first, it->second);
            strcat(dataSent, str);
            free(str);
        }
        // strcat(dataSent, "]");
        dataSent[strlen(dataSent) - 1] = '}';
              
        // printf("%s\n", dataSent);
        g_autofree gchar *data = g_strdup_printf("%s", dataSent);
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
  }
  else if (strcmp(method, "receiveS4") == 0) {
    std::cout <<"S4_T.size(): " <<S4_T.size()<<"\n";
      if(toend == 0 && S4_T.size() < 1) {
        g_autofree gchar *data = g_strdup_printf("%s", "end");
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
      else {
        std::map<int, double> S4_T_pair;
        S4_T_pair = S4_T.pop_front();
        int ELEMENTSIZE = 32;
        int BUFSIZE = S4_T_pair.size()*ELEMENTSIZE;
        char dataSent[BUFSIZE];
        strcpy(dataSent, "");
        strcat(dataSent, "{");
        std::map<int,float>::iterator itSNR;
        double S4N0_2 = 0, SNR = 0, S4_T = 0, SI_2 = 0;
        for(auto it = S4_T_pair.cbegin(); it != S4_T_pair.cend(); ++it)
        {
            // std::cout << it->first << " " << it->second<< "\n";
            char *str = (char*) malloc(sizeof(char) * ELEMENTSIZE);
            // snprintf(str, ELEMENTSIZE, "\"%d\":%.5lf,", it->first, it->second);
            S4_T = it->second;
            itSNR = listCN0.find(it->first);
             if (itSNR == listCN0.end()) {
              snprintf(str, ELEMENTSIZE, "\"%d\":%.5lf,", it->first, 0.0);
             }
             else {
              SNR = itSNR->second * 1000;
              // std::cout << "SNR "<< SNR<< "\n";
              if(S4_T == 0.0 || SNR == 0.0) {
                snprintf(str, ELEMENTSIZE, "\"%d\":%.5lf,", it->first, 0.0);
              }
              else {
                S4N0_2 = (100/SNR)*(1+500/(19*SNR));
                // std::cout << "S4N0_2 "<< S4N0_2<< "\n";
                // std::cout << "S4_T "<< S4_T << "\n";
                SI_2 = S4_T*S4_T - S4N0_2;
                // std::cout << "SI_2 "<< SI_2 << "\n";
                if(SI_2 > 0.0) {
                  snprintf(str, ELEMENTSIZE, "\"%d\":%.5lf,", it->first, sqrt(SI_2));
                }
                else {
                  snprintf(str, ELEMENTSIZE, "\"%d\":%.5lf,", it->first, 0.0);
                }
              }
             }
            strcat(dataSent, str);
            free(str);
        }
        // strcat(dataSent, "]");
        dataSent[strlen(dataSent) - 1] = '}';
              
        // printf("%s\n", dataSent);
        g_autofree gchar *data = g_strdup_printf("%s", dataSent);
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
  } 
  else if (strcmp(method, "sendData") == 0) {
    std::thread receiveDataThread(receiveData);
    // std::thread calculateS4Thread(calculateS4);
    receiveDataThread.detach();
    // calculateS4Thread.detach();

    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  }
  else if (strcmp(method, "endData") == 0) {
    struct my_msgbuf buf;
    int msqid;
    key_t key;
    // system("touch /tmp/tracking.txt");

    int MSIZE = 4;

    const char* file = "/tmp/controlling.txt";
    int BUFSIZE = 32;
    char *cmd = (char*) malloc(sizeof(char) * BUFSIZE);
    snprintf(cmd, BUFSIZE, "touch %s", file);
    system(cmd);
    free(cmd);
    
    if ((key = ftok(file, 'B')) == -1) {
        perror("ftok");
        // exit(1);
    }
    if ((msqid = msgget(key, PERMS | IPC_CREAT)) == -1) {
        perror("msgget");
        // exit(1);
    }

    char *str = (char*) malloc(sizeof(char) * MSIZE);
    snprintf(str, MSIZE, "end");
    strcpy(buf.mtext, str);
    if (msgsnd(msqid, &buf, MSIZE, 0) == -1) /* +1 for '\0' */
    perror("msgsnd");
    free(str);

    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  }
  else if (strcmp(method, "initMessageQueue") == 0) {
    
    const char* file = "/tmp/tracking.txt";
    int BUFSIZE = 32;
    char *cmd = (char*) malloc(sizeof(char) * BUFSIZE);
    snprintf(cmd, BUFSIZE, "touch %s", file);
    system(cmd);
    free(cmd);
    
    if ((key = ftok(file, 'B')) == -1) {
        perror("ftok");
        // exit(1);
    }
    
    if ((msqid = msgget(key, PERMS | IPC_CREAT)) == -1) {
      perror("msgget");
      // exit(1);
    }

    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  }
  else if (strcmp(method, "endMessageQueue") == 0) {
    if (msgctl(msqid, IPC_RMID, NULL) == -1) {
      perror("msgctl");
      // exit(1);
    }
    system("rm /tmp/tracking.txt");

    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  }
  else if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  } 
  else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
  }
}

static void new_linux_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(new_linux_plugin_parent_class)->dispose(object);
}

static void new_linux_plugin_class_init(NewLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = new_linux_plugin_dispose;
}

static void new_linux_plugin_init(NewLinuxPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  NewLinuxPlugin* plugin = NEW_LINUX_PLUGIN(user_data);
  new_linux_plugin_handle_method_call(plugin, method_call);
}

void new_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  NewLinuxPlugin* plugin = NEW_LINUX_PLUGIN(
      g_object_new(new_linux_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "new_linux_plugin",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
