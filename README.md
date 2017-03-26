# docker-plugins

A Docker container for running [plugn](https://github.com/progrium/plugn) plugins that respond to Docker events, and a builtin collection of generally useful Docker plugins.

## Using docker-plugins

	$ docker pull progrium/plugins

Once you have it, before using it, you can see plugins by running the `plugn list` command on it:

	$ docker run --rm progrium/plugins plugn list

The builtin plugins are all disabled by default. You can enable plugins by setting environmant variable `ENABLE` with a space delimited list of plugin names to enable.

To actually run docker-plugins, you mount your Docker socket and use the default command. Here we'll enable several plugins. You typically run docker-plugins detached, but for now, we'll run it with `-it` to see output and easily close it. 

	$ docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e "ENABLE=autoremove timeout" \
		progrium/plugins

Before starting, it will always show you the current state of plugins inside the container. 

Most plugins are configured via environment variables. For example, here we run docker-plugins with the webhooks plugin enabled and giving it a RequestBin URL to use for all events.

	$ docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e "ENABLE=webhooks" \
		-e "WEBHOOKS_URL=http://requestb.in/ysr016ys" \
		progrium/plugins

## Installing plugins

Plugins can be installed from any Git repository. The `plugn install` command is invoked automatically at boot when setting the `INSTALL` environment variable with a space delimited list of Git repository URLs. These plugins must also be enabled to activate them.

	$ docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e "INSTALL=https://github.com/progrium/docker-plugin-demo.git"
		-e "ENABLE=docker-plugin-demo" \
		progrium/plugins

## Writing plugins

Plugins are simply directories of executable hook scripts for available hooks, similar to Dokku plugins, and a plugin.toml file. The `plugn` tool helps manage these plugins. It is still a work in progress, but will eventually also help manage compatibility and configuration. 

Plugins can also implement a `dependencies` hook. The first argument is the plugin name, and this can be used to optionally trigger installing dependencies in use by your plugin.

### Hook scripts

Hook scripts are called by `plugn`, but ultimately triggered by [dockerhook](https://github.com/progrium/dockerhook). For every event from the Docker stream, dockerhook triggers our plugn hooks passing it the container ID as the first argument, and inspected JSON of the container if available via STDIN. It would be *similar* to a command like this:

	$ docker inspect $id | your-hook $id

However, the JSON passed in is a single object, not a list of objects like the output of `docker inspect`. 

### Builtin tools for hooks

The container environment is based on `ubuntu:14.04`. The `docker` binary is installed so you can interact with Docker. The following are some other packages made available to you:

- `curl` for http access.
- `git` for use with installing plugins.
- `jq` is installed for handling JSON data.

### Available hooks

To implement a hook, just create an executable shell script named after any supported hook.

 * exists - custom hook for containers found at boot before listening for events
 * create
 * destroy
 * die
 * export
 * kill
 * pause
 * restart
 * start
 * stop
 * unpause
 * untag - supported but not used by builtin plugins
 * delete - supported but not used by builtin plugins

## License

BSD
