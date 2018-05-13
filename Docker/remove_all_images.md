# Cleaning your docker environment

When you uninstall an ICp environment, you could wish to clean the docker engine from existing containers or images

By default, Docker provides command (`rm` and `rmi`) but they work one item by one. To accelarate the cleaning, you could wish to do it by one command.

Here is the command to facilate this action

* *Delete all the containers*

```
docker rm $(docker ps -a -q)
```

* *Delete all images*

```
docker rmi $(docker images -q)
```
