This is a docker-plugin aims to send HipChat messages to a specific
room at each docker event: start/stop/create/destroy ...

## Configuration

You need 2 configuration value set as environment variable:

```
export HIPCHAT_TOKEN=<40-ALFANUM>
export HIPCHAT_ROOM_ID=<6-DIGITS>
```

### Token

You get your personal OAuth2 API token on the
[account page](https://sequenceiq.hipchat.com/account/api)

### Room id

list hipchat room ids
```
curl "https://api.hipchat.com/v2/room?auth_token=$HIPCHAT_TOKEN" \
  | jq '.items[]|[.id,.name]' -c
```

## Usage

Installing and enabling the hipchat plugin

```
docker run -it --rm \
  -e DEBUG=1 \
  -e "ENABLE=hipchat" \
  -e "HIPCHAT_TOKEN=$HIPCHAT_TOKEN" \
  -e "HIPCHAT_ROOM_ID=$HIPCHAT_ROOM_ID" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  progrium/plugins
```

It will send messages like this:

```
Container: exists Name=/agitated_brown Image=progrium/plugins IPAddress=172.17.0.13
Container: create Name=/webserver Image=nginx IPAddress=172.17.0.4
Container: start Name=/webserver Image=nginx IPAddress=172.17.0.4
```

## Message format

Right now the message starts with the name of the event, than a minimal
information is displayed about the container: name, image, ip.

The message is created with the Docker container JSON piped into [jq](http://stedolan.github.io/jq/). 
The jq filter starts with the hook name, and then contains the following fields:

- .Name  
- .Config.Image
- .NetworkSettings.IPAddress

It can be customized via the `HIPCHAT_MSG_FIELDS` environment var. Its a coma
sparated list of JSON fields. For example to include the **Path** of the running process

```
docker run -it --rm \
  -e DEBUG=1 \
  -e "ENABLE=hipchat" \
  -e "HIPCHAT_TOKEN=$HIPCHAT_TOKEN" \
  -e "HIPCHAT_ROOM_ID=$HIPCHAT_ROOM_ID" \
  -e "HIPCHAT_MSG_FIELDS=.Name,.Config.Image,.NetworkSettings.IPAddress,.Path" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  progrium/plugins
```

It will generate a similar hipchat message:
```
Container: exists Name=/cadvisor Image=google/cadvisor:latest Path=/usr/bin/cadvisor
```

## Unit testing the jq filter

checking the jq filter in isolation
```
./filter_test
```

## Hacking

To be able to test without commiting/pushing changes to github, use volumes.

```
docker run -it --rm \
  -e DEBUG=1 \
  -e "ENABLE=hipchat" \
  -e "HIPCHAT_TOKEN=$HIPCHAT_TOKEN" \
  -e "HIPCHAT_ROOM_ID=$HIPCHAT_ROOM_ID" \
  -v $(pwd):/plugins/available/hipchat \
  -v /var/run/docker.sock:/var/run/docker.sock \
  progrium/plugins
```

checking the jq filter with plugn configuration applied
```
eval $(PLUGIN_PATH=./plugins plugn config export hipchat) && ./filter_test
```
