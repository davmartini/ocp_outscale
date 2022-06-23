resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tmpl",
    {
     ip_infravm = outscale_vm.ocp-infravm.private_ip
     ip_ocp-bootstrap = outscale_vm.ocp-bootstrap[*].private_ip
     ip_ocp-master = outscale_vm.ocp-master[*].private_ip
     ip_ocp-worker = outscale_vm.ocp-worker[*].private_ip
    }
  )
  filename = "../ansible/templates/inventory.j2"
}

resource "local_file" "named" {
  content = templatefile("templates/named.tmpl",
    {
     ip_infravm = outscale_vm.ocp-infravm.private_ip
    }
  )
  filename = "../ansible/templates/named.conf.j2"
}

resource "local_file" "nameddb" {
  content = templatefile("templates/nameddb.tmpl",
    {
     ip_infravm = outscale_vm.ocp-infravm.private_ip
     ip_ocp-bootstrap = outscale_vm.ocp-bootstrap[*].private_ip
     ip_ocp-master = outscale_vm.ocp-master[*].private_ip
     ip_ocp-worker = outscale_vm.ocp-worker[*].private_ip
    }
  )
  filename = "../ansible/templates/nameddb.j2"
}

resource "local_file" "namedrev" {
  content = templatefile("templates/namedrev.tmpl",
    {
     ip_infravm = outscale_vm.ocp-infravm.private_ip
     ip_ocp-bootstrap = outscale_vm.ocp-bootstrap[*].private_ip
     ip_ocp-master = outscale_vm.ocp-master[*].private_ip
     ip_ocp-worker = outscale_vm.ocp-worker[*].private_ip
    }
  )
  filename = "../ansible/templates/namedrev.j2"
}

resource "local_file" "haproxy" {
  content = templatefile("templates/haproxy.tmpl",
    {
     ip_infravm = outscale_vm.ocp-infravm.private_ip
     ip_ocp-bootstrap = outscale_vm.ocp-bootstrap[*].private_ip
     ip_ocp-master = outscale_vm.ocp-master[*].private_ip
     ip_ocp-worker = outscale_vm.ocp-worker[*].private_ip
    }
  )
  filename = "../ansible/templates/haproxy.j2"
}