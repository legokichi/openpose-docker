#!/usr/bin/python3
import sys
import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import argparse
import subprocess
import re

class MyEventHandler(FileSystemEventHandler):
    def __init__(self, out_dir):
        super().__init__()
        self.out_dir = out_dir
    def on_created(self, ev):
        print(ev)
        if re.search('\.mp4$', ev.src_path) == None:
            return
        out_prefix = os.path.join(self.out_dir + os.path.basename(ev.src_path))
        com = """
        NV_GPU=0,3 nvidia-docker run \
         --rm -ti \
         -v /nfs/:/nfs/ \
         openpose-docker:9.0 \
           /opt/openpose/build/examples/openpose/openpose.bin \
             --no_display 1 --num_gpu 2 \
             --video {} \
             --write_video {}.openpose.mp4 \
             --write_keypoint_json {}.keypoint 
        """.format(ev.src_path, out_prefix, out_prefix)
        print(com)
        ret = subprocess.call(com, shell=True)
        if ret != 0:
            print("error", ret)

def main_unit(watch_dir, out_dir):
    observer = Observer()
    event_handler = MyEventHandler(out_dir)
    observer.schedule(event_handler, watch_dir, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(5)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()



def daemonize(watch_dir, out_dir):
    pid = os.fork()
    if pid > 0:
        pid_file = open('/var/run/nfs_watch.pid','w')
        pid_file.write(str(pid)+"\n")
        pid_file.close()
        sys.exit()
    if pid == 0:
        main_unit(watch_dir, out_dir)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='watch')
    parser.add_argument('--dir', default=".", help='watch dir')
    parser.add_argument('--out', default="./out/", help='output dir')
    parser.add_argument('--daemon', action="store_true", help='daemon mode')
    args = parser.parse_args()
    if args.daemon:
        while True:
            daemonize(args.dir, args.out)
    else:
        main_unit(args.dir, args.out)




