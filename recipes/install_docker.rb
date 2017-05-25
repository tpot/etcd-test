package "docker.io"
package "etcd-client"

docker_image "debian" do
  tag "sid"
  action :pull
end

directory "/tmp/debian-etcd" do
  action :create
end

file "/tmp/debian-etcd/Dockerfile" do
  content <<-EOF
  FROM debian:sid
  RUN apt-get update && apt-get install etcd -y
  EXPOSE 2379 2380
  EOF
  action :create
end

docker_image "debian-etcd" do
  source "/tmp/debian-etcd"
  action :build_if_missing
end

# Static cluster

docker_network "etcd-network" do
  subnet "192.168.10.0/24"
  gateway "192.168.10.1"
  action :create
end

initial_cluster = ""

[10,11,12,13].each do |n|
  initial_cluster << "node#{n}=http://192.168.10.#{n}:2380,"
end

[10,11,12,13].each do |n|

  node_ip = "192.168.10.#{n}"

  docker_container "node#{n}" do
    repo "debian-etcd"
    command "/usr/bin/etcd --name node#{n} " \
          "--initial-advertise-peer-urls http://#{node_ip}:2380 " \
          "--listen-peer-urls http://#{node_ip}:2380 " \
          "--listen-client-urls http://#{node_ip}:2379 " \
          "--advertise-client-urls http://#{node_ip}:2379 " \
          "--initial-cluster-token etcd-cluster " \
          "--initial-cluster #{initial_cluster} " \
          "--initial-cluster-state new"
    network_mode "etcd-network"
    ip_address node_ip
    action :run_if_missing
  end
  
end
