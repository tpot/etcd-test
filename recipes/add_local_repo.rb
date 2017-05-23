apt_repository "etcd-tpot" do
  uri "http://192.168.1.21:8091"
  distribution "sid"
  components ["main"]
  key "6EBBE84D"
end
