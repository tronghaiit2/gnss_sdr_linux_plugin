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

std::map<int, float> listData;

void receiveData() {
  std::map<int, float> list_Data;
  long diff;
  std::chrono::time_point<std::chrono::system_clock> start, end;
  start = std::chrono::system_clock::now();
  for(;;) {
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
          if(diff > 800 && list_Data.empty()) {
            toend = 0;
            break;
          }
        }
      else {
        perror("msgrcv");
      }
    } 
    else {
      std::vector<float> data_list;
      std::stringstream ss;
      ss << buf.mtext;
      while(!ss.eof()){
          std::string x;
          ss >> x;
          float y = atof(x.c_str());
          if(y > 0) data_list.push_back(y);
      }
      list_Data.insert(std::make_pair(data_list[0], data_list[1]));
      // std::map<int, float>::iterator it = listData.find(data_list[0]); 
      // if (it == listData.end()) {
      //   listData.insert(std::make_pair(data_list[0], data_list[1]));
      // }
      // else {
      //   if(data_list[1] > it->second) {
      //     it->second = data_list[1];
      //   } 
      // }

      // printf("recvd: %s\n", buf.mtext);
      toend = strcmp(buf.mtext,"end");
      if (toend == 0 || sizeof(buf.mtext) == 0) 
      break;
    }
  }
  listData = list_Data;
}

// Called when a method call is received from Flutter.
static void new_linux_plugin_handle_method_call(
    NewLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "receiveData") == 0) {
      // std::thread receiveDataThread(receiveData);
      // receiveDataThread.join();
      // receiveDataThread.detach();
      if(toend == 0 && listData.empty()) {
        g_autofree gchar *data = g_strdup_printf("%s", "end");
        g_autoptr(FlValue) result = fl_value_new_string(data);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
      }
      else {
        int ELEMENTSIZE = 20;
        int BUFSIZE = listData.size()*ELEMENTSIZE;
        char dataSent[BUFSIZE];
        strcpy(dataSent, "");
        strcat(dataSent, "{");
        // strcat(dataSent, "[{\"ID\":0}");
        for(auto it = listData.cbegin(); it != listData.cend(); ++it)
        {
            // std::cout << it->first << " " << it->second<< "\n";
            char *str = (char*) malloc(sizeof(char) * ELEMENTSIZE);
            snprintf(str, ELEMENTSIZE, "\"%d\":%f,", it->first, it->second);
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
    receiveDataThread.detach();

    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  }
  else if (strcmp(method, "endData") == 0) {
    strcpy(buf.mtext, "end");
    if (msgsnd(msqid, &buf, 4, 0) == -1) /* +1 for '\0' */
    perror("msgsnd");

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
