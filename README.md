# Learning 6-DoF Grasping and Pick-Place Using Attention Focus

This is the code for reproducing experiments in the paper, ["Learning 6-DoF Grasping and Pick-Place Using Attention Focus"](https://arxiv.org/abs/1806.06134).

## Requirements

- nvidia-docker

## Build docker image

```
docker build . -t image_name
docker run --runtime nvidia -it --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" image_name:latest
```

Adjust the X server host permissions.

```
xhost +local:root
```

## Test your installation

All the following commands must be run in the container.

1: Update `PYTHONPATH` inside the docker container.

```
export PYTHONPATH=$PYTHONPATH:/PointCloudsPython:/caffe/python
```

2: Check if OpenGL is working.

```
glxgears
```

3: Check if caffe and point_cloud are installed.

```
python
>>> import caffe
>>> import point_cloud
>>> 
```

## Running

Coming soon