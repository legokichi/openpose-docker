## build

```sh
nvidia-docker build -t openpose-docker:9.0 .
```

## daemon

* https://qiita.com/croquisdukke/items/9c5d8933496ba6729c78


```sh
/opt/openpose-docker/

mv nfs_watch_daemon.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start nfs_watch_daemon.service
```

## DGX-1


```sh
NV_GPU=0,3 nvidia-docker run \
  --rm -ti \
  -v /nfs/:/nfs/ \
  openpose-docker:9.0 \
    /opt/openpose/build/examples/openpose/openpose.bin \
      --no_display 1 --num_gpu 2 \
      --video /nfs/a.mp4 \
      --write_video /nfs/b.mp4 \
      --write_keypoint_json /nfs/a.keypoint
```


