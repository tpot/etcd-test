package "docker.io"

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

docker_container "node1" do
  repo "debian-etcd"
  command "/usr/bin/etcd"
  action :run_if_missing
end
