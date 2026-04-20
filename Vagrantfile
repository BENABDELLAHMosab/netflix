Vagrant.configure("2") do |config|
  # Option A (recommandée) : Debian 12 — télécharger avec : vagrant box add generic/debian12 --provider vmware_desktop
  config.vm.box = "generic/debian12"
  # Option B (déjà présente) : Ubuntu 18.04 — décommenter pour démarrer immédiatement
  # config.vm.box = "hashicorp/bionic64"
  config.vm.boot_timeout = 600

  machines = [
    { name: "vm1-access",  ip: "10.10.10.11", mem: 1024, cpu: 1, script: "provision/vm1_access.sh"  },
    { name: "vm2-app",     ip: "10.10.10.12", mem: 1536, cpu: 1, script: "provision/vm2_app.sh"     },
    { name: "vm3-db",      ip: "10.10.10.13", mem: 1536, cpu: 1, script: "provision/vm3_db.sh"      },
    { name: "vm4-object",  ip: "10.10.10.14", mem: 2048, cpu: 1, script: "provision/vm4_object.sh"  },  # MinIO recommande min 2 GB
    { name: "vm5-monitor", ip: "10.10.10.15", mem: 2048, cpu: 1, script: "provision/vm5_monitor.sh" }   # Prometheus + Grafana
  ]

  machines.each do |m|
    config.vm.define m[:name] do |node|
      node.vm.hostname = m[:name]
      node.vm.network "private_network", ip: m[:ip]

      if m[:name] == "vm1-access"
        node.vm.network "forwarded_port", guest: 80,  host: 8080, auto_correct: true
        node.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
        node.vm.network "forwarded_port", guest: 22,  host: 2221, auto_correct: true
      end

      if m[:name] == "vm4-object"
        node.vm.network "forwarded_port", guest: 9000, host: 9000, auto_correct: true  # MinIO API
        node.vm.network "forwarded_port", guest: 9001, host: 9001, auto_correct: true  # MinIO WebUI
      end

      node.vm.provider "vmware_desktop" do |v|
        v.gui = false
        v.vmx["memsize"] = m[:mem].to_s
        v.vmx["numvcpus"] = m[:cpu].to_s
        v.vmx["displayName"] = m[:name]
      end

      node.vm.provision "shell", path: "provision/common.sh"
      node.vm.provision "shell", path: m[:script]
    end
  end
end