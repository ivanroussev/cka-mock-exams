kc main -n ci-pipeline create serviceaccount deployer
kc main -n ci-pipeline create role deploy-manager --verb=get,list,watch,create,update,patch --resource=deployments
kc main -n ci-pipeline patch role deploy-manager --type=json \
  -p='[{"op":"add","path":"/rules/-","value":{"apiGroups":[""],"resources":["pods"],"verbs":["get","list"]}}]'
kc main -n ci-pipeline create rolebinding deployer-binding --role=deploy-manager --serviceaccount=ci-pipeline:deployer
