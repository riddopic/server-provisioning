# healthcheck-cookbook


## Description

This is the camunda continuous integration base cookbook. It is the foundation used to setup the ci infrastructure for camunda bpm.This is the camunda continuous integration setup aggregation cookbook. It is used to setup the ci infrastructure for camunda bpm.


## Supported Platforms

* Ubuntu 14.04


## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['healthcheck']['users']</tt></td>
    <td>String array</td>
    <td>Creates mentioned users. Create a databag for each given user under `users/<myuser>`</td>
    <td><tt>['ciuser']</tt></td>
  </tr>
  <tr>
    <td><tt>['healthcheck']['docker']['group_members']</tt></td>
    <td>String array</td>
    <td>Assign the given users to the docker group so no sudo is required when executing docker commands</td>
    <td><tt>['ciuser']</tt></td>
  </tr>
  <tr>
    <td><tt>['healthcheck']['docker']['host']</tt></td>
    <td>String array</td>
    <td>Specify to which IPs:ports and sockets the docker host should be bound</td>
    <td><tt>['127.0.0.1:2375', 'unix:///var/run/docker.sock']</tt></td>
  </tr>
  <tr>
    <td><tt>['healthcheck']['ntp']['servers']</tt></td>
    <td>String array</td>
    <td>Connect to the given ntp servers for clock synchronization</td>
    <td><tt>[]</tt></td>
  </tr>
</table>


## Usage

### healthcheck::default

Include `healthcheck` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[healthcheck::default]"
  ]
}
```

### Testing and Development

Please see information in [VAGRANT](VAGRANT.md) for how to use the Vagrant environment.
Full development and testing workflow with Test Kitchen and friends [TESTING](TESTING.md)


## Contributing

Please see contributing information in: [CONTRIBUTING](CONTRIBUTING.md)


## Maintainers

Author:: Christian Lipphardt (<christian.lipphardt@camunda.com>)


## License

Please see licensing information in: [LICENSE](LICENSE)

