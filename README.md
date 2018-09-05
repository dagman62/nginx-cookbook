# nginx

## This cookbook was primarily created for my Tomcat Q/A testing you can overrided the port by creating a wrapper cookbook and overriding the port via the attributes

### in the metadata.rb
```
depends 'nginx', ~= '1.0.0'
```
### in the recipe/default.rb
```
include_recipe 'nginx::default'
```
### in the attributes/default.rb

```
force_default['app']['port'] = 'mynewport'
```

