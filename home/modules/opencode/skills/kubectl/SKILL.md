---
name: kubectl
description: Read-only Kubernetes cluster inspection via kubectl
---

# Kubectl Skill (Read-Only)

Use this skill when you need to inspect Kubernetes clusters without modifying their state.

## Kubeconfig Usage

Always resolve kubeconfigs from `~/pinniped-kubeconfigs`:
```bash
KUBECONFIG=~/pinned-kubeconfigs/<cluster-kubeconfig> kubectl <command>
```

When multiple clusters exist and the user hasn't specified one, ask the user which cluster to target.

## Allowed Commands

You may ONLY use the following kubectl commands:

| Command | Use Case |
|---------|----------|
| `kubectl get` | List/watch resources |
| `kubectl describe` | Detailed resource inspection |
| `kubectl logs` | Retrieve pod logs |
| `kubectl top` | Resource utilization |
| `kubectl explain` | API documentation |
| `kubectl events` | Cluster events |
| `kubectl api-resources` | Available resource types |
| `kubectl cluster-info` | Cluster endpoints |
| `kubectl auth can-i` | Permission checking |

## Forbidden Commands

**NEVER run these commands:**
- `kubectl apply` (direct cluster modifications)
- `kubectl edit` (opens editor for modifications)
- `kubectl patch` (JSON/strategic merge patches)
- `kubectl replace` (replace resources)
- `kubectl delete` (delete resources)
- `kubectl label` (add/modify labels)
- `kubectl annotate` (add/modify annotations)
- `kubectl create` (create resources)
- `kubectl run` (create pods/deployments)
- `kubectl rollout` (deployment management)
- `kubectl scale` (scale resources)

## Common Inspection Patterns

### Pod Diagnostics
```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl logs <pod-name> -n <namespace> -c <container-name>
```

### Deployment Inspection
```bash
kubectl get deployments -n <namespace>
kubectl describe deployment <name> -n <namespace>
kubectl rollout history deployment/<name> -n <namespace>
```

### Resource Events
```bash
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl get events -n <namespace> --field-selector involvedObject.name=<resource>
```

### Cross-Namespace
```bash
kubectl get pods --all-namespaces
kubectl get events --all-namespaces
```

## Manifest Modification Workflow

When the user needs to modify a resource, you must NOT apply changes directly. Instead:

1. **Fetch the manifest:**
   ```bash
   mkdir -p /tmp/<cluster-name>/
   KUBECONFIG=~/pinniped-kubeconfigs/<cluster-kubeconfig> kubectl get -o yaml <resource-type> <resource-name> -n <namespace> > /tmp/<cluster-name>/<namespace>-<resource-name>-.yaml
   ```

2. **Edit the file locally** in `/tmp/<cluster-name>/`

3. **Instruct the user** to apply the manifest themselves, providing:
   - The exact `kubectl apply` command
   - A clear explanation of all modifications
   - Why these changes are necessary
   - Any potential risks or rollback considerations

4. **Always suggest GitOps alternatives** when applicable (e.g., fixing a Flux Kustomization instead of editing a Deployment directly)

## Tips

- Use `-o wide` for additional columns in output
- Use `-o yaml` or `-o json` for machine-readable output
- Use `-w` flag to watch for changes in real-time
- Use `--show-labels` to display all labels on resources
