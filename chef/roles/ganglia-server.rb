# -*- encoding : utf-8 -*-

name "ganglia-server"
description "GANGLIA Server Role - GANGLIA master for the cloud"
run_list(
  "recipe[ganglia::server]"
)
default_attributes()
override_attributes()

