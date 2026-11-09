```bash
# On cp1
kubeadm token create --ttl 2h --print-join-command > /root/join-command.txt
kubeadm token list          # the new token shows a TTL of ~1h59m (the init token: ~23h)
cat /root/join-command.txt
```

`--print-join-command` saves you computing the CA hash by hand. If you ever need it (docs: **"kubeadm join"**):
```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null \
  | openssl dgst -sha256 -hex | sed 's/^.* //'
```

**Pitfalls:** the default TTL is 24h — `--ttl 2h` is what the task asks for. `kubeadm token generate` only prints a random
string; it does not create the token in the cluster (`kubeadm token create <that string> --ttl 2h` would).
