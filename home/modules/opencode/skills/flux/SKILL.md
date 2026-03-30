---
name: flux
description: Read-only Flux GitOps toolkit introspection
---

# Flux Skill (Read-Only)

Use this skill when inspecting Flux GitOps reconciliation status and Flux-managed resources.

## Flux CLI Usage

Flux requires a kubeconfig just like kubectl:
```bash
KUBECONFIG=~/pinniped-kubeconfigs/<cluster-kubeconfig> flux <command>
```

## Allowed Commands

You may ONLY use the following Flux commands for inspection:

| Command | Use Case |
|---------|----------|
| `flux get` | List Flux resources |
| `flux get all` | All Flux resources |
| `flux get sources` | Source controllers status |
| `flux get source git` | GitRepository sources |
| `flux get source helm` | HelmRepository/HelmRelease sources |
| `flux get kustomizations` | Kustomization status |
| `flux get hr` | HelmReleases |
| `flux describe` | Detailed resource description |
| `flux events` | Flux controller events |
| `flux tree` | Resource tree (dependencies) |
| `flux status` | Overall Flux installation status |

## Forbidden Commands

**NEVER run these commands:**
- `flux reconcile` (force reconciliation)
- `flux suspend` (pause reconciliation)
- `flux resume` (resume reconciliation)
- `flux create` (create Flux resources)
- `flux delete` (delete Flux resources)
- `flux bootstrap` (install Flux)
- `flux uninstall` (remove Flux)
- `flux reconcile source` (reconcile sources)
- `flux set` (modify Flux settings)

## Inspection Patterns

### Overall Flux Status
```bash
flux status
flux get all
```

### Source Controllers
```bash
flux get sources all
flux get source git
flux get source helm
```

### GitRepository Details
```bash
flux describe source git <name>
flux events --for=GitRepository/<name>
```

### Kustomization Status
```bash
flux get kustomizations
flux describe kustomization <name>
flux tree kustomization <name>
```

### HelmRelease Inspection
```bash
flux get hr -n <namespace>
flux describe hr <name> -n <namespace>
```

### Troubleshooting
```bash
flux events --since=1h
kubectl get gitrepositories -A
kubectl get kustomizations -A
```

## GitOps Workflow

When Flux shows issues, follow this diagnostic approach:

1. **Check Sources**: Are GitRepository/HelmRepository sources ready?
   ```bash
   flux get sources git
   flux describe source git <name>
   ```

2. **Inspect Kustomizations**: What is the last reconciliation status?
   ```bash
   flux get kustomizations
   flux describe kustomization <name>
   ```

3. **Review Events**: What happened recently?
   ```bash
   flux events --for=Kustomization/<name>
   ```

4. **Identify Root Cause**: Common issues include:
   - Invalid Git reference (branch/tag/commit)
   - Authentication failures (SSH keys, tokens)
   - Malformed manifests in the Git repository
   - Resource conflicts or validation errors

5. **Propose GitOps Solution**: Always suggest fixing the issue in the Git repository rather than modifying cluster resources directly.

## Common Flux Resources

| Resource | Kind | Purpose |
|----------|------|---------|
| GitRepository | source.toolkit.fluxcd.io | Git source repository |
| HelmRepository | source.toolkit.fluxcd.io | Helm chart repository |
| HelmChart | source.toolkit.fluxcd.io | Helm chart artifact |
| Bucket | source.toolkit.fluxcd.io | S3-compatible bucket source |
| Kustomization | kustomize.toolkit.fluxcd.io | Reconciliation target |
| HelmRelease | helm.toolkit.fluxcd.io | Helm chart deployment |
| ImagePolicy | image.toolkit.fluxcd.io | Container image updates |
| ImageUpdateAutomation | image.toolkit.fluxcd.io | Automated image updates |

## Tips

- Use `flux tree kustomization <name>` to see all resources managed by a Kustomization
- Check `flux events` for detailed error messages
- Use `flux get sources --all-namespaces` for cluster-wide source status
- Look at the `.status.conditions` in `flux describe` output for reconciliation errors
