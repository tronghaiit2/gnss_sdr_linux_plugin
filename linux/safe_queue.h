//
// Created by vtcc-quanvm4 on 22/03/2022.
//

#ifndef NCNN_ANDROID_YOLOV5_FACE_SAFE_QUEUE_H
#define NCNN_ANDROID_YOLOV5_FACE_SAFE_QUEUE_H

#include <queue>
#include <mutex>
#include <condition_variable>
#include <unistd.h>
#include <iostream>

template <typename T>
class SharedQueue
{
public:
    SharedQueue();
    ~SharedQueue();

    //T& front();
    T pop_front();

    void push_back(const T& item);
    void push_back(T&& item);

    int size();
    bool empty();

private:
    std::deque<T> queue_;
    std::mutex mutex_;
    std::condition_variable cond_;
};

template <typename T>
SharedQueue<T>::SharedQueue(){}

template <typename T>
SharedQueue<T>::~SharedQueue(){}

// template <typename T>
// T& SharedQueue<T>::front()
// {
//     std::unique_lock<std::mutex> mlock(mutex_);
//     while (queue_.empty())
//     {
//         cond_.wait(mlock);
//     }
//     return queue_.front();
// }

template <typename T>
T SharedQueue<T>::pop_front()
{
    std::unique_lock<std::mutex> mlock(mutex_);
    while (queue_.empty())
    {
        cond_.wait(mlock);
    }
    T value = queue_.front();
    queue_.pop_front();
    return value;
}

template <typename T>
void SharedQueue<T>::push_back(const T& item)
{
    std::unique_lock<std::mutex> mlock(mutex_);
    queue_.push_back(item);
    mlock.unlock();     // unlock before notificiation to minimize mutex con
    cond_.notify_one(); // notify one waiting thread

}

template <typename T>
void SharedQueue<T>::push_back(T&& item)
{
    std::unique_lock<std::mutex> mlock(mutex_);
    queue_.push_back(std::move(item));
    mlock.unlock();     // unlock before notificiation to minimize mutex con
    cond_.notify_one(); // notify one waiting thread

}

template <typename T>
int SharedQueue<T>::size()
{
    std::unique_lock<std::mutex> mlock(mutex_);
    int size = queue_.size();
    mlock.unlock();
    return size;
}

#endif //NCNN_ANDROID_YOLOV5_FACE_SAFE_QUEUE_H
