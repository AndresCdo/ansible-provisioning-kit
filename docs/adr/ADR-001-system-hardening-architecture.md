# ADR-001: System Hardening Architecture for Ansible Provisioning Kit

**Date:** 2026-05-01
**Status:** Accepted
**Authors:** @build
**Reviewers:** @security, @architect

## Context

The Ansible Provisioning Kit automates the setup of development/infrastructure environments including Docker, Podman, Jenkins, Kubernetes, cloud CLIs, and CI/CD tools. A security audit (2026-05-01) identified 6 critical, 9 high, 7 medium, and 5 low-severity findings across the provisioning playbooks and host system.

The primary security gaps are:
1. Kernel security parameters not configured
2. No filesystem module restrictions  
3. No TLS on reverse proxy (Jenkins via NGINX)
4. No logging/auditing configuration beyond basic auditd installation
5. No secrets management for Ansible
6. SSH host key verification disabled
7. Jenkins admin password exposed in plaintext in Ansible output

## Options considered

### Option A: Extend existing hardening role

Add all new hardening measures to `roles/hardening/tasks/main.yml` as additional blocks.

**Pros:**
- Single role contains all system hardening
- Consistent tagging (`tags: hardening`)
- Reuses existing handler infrastructure
- Easy to understand: one place for all security config

**Cons:**
- File grows large (~500+ lines)
- Some configs (NGINX TLS, Jenkins no_log) belong in their respective roles
- Mixing concerns: kernel params, audit rules, and module blacklisting are different domains

**Implementation complexity:** Low
**Reversibility:** Easy

### Option B: Split hardening into sub-roles

Create `roles/hardening/` with `tasks/` subdirectories: `kernel.yml`, `filesystem.yml`, `logging.yml`, `ssh.yml`, `pam.yml`.

**Pros:**
- Separation of concerns per security domain  
- Easier to maintain and audit individual components
- Can be included conditionally

**Cons:**
- More files, more complexity
- Overkill for current scope; the existing pattern in this repo uses single tasks/main.yml per role

**Implementation complexity:** Medium
**Reversibility:** Easy

### Option C: Do nothing

Accept current security posture.

**Pros:**
- No effort required

**Cons:**
- CIS Level 1 benchmark non-compliance in 12+ categories
- Unpatched attack surface: databases exposed to network, no TLS, kernel protections missing
- Compliance risk for PCI-DSS, SOC2, HIPAA contexts

**Implementation complexity:** N/A
**Reversibility:** N/A

## Decision

**We choose: Option A — Extend existing hardening role** with two exceptions:
- NGINX TLS configuration stays in `roles/nginx/` (component owns it)
- Jenkins `no_log` configuration stays in `roles/jenkins/` (component owns it)

Rationale:
- Matches the existing architectural pattern of this repository (single `tasks/main.yml` per role)
- All new hardening tasks are tagged `hardening` for selective execution
- The hardening role already has handlers for SSHD, UFW, auditd, and Fail2Ban — no new handlers needed for most additions
- The CIS Benchmark-aligned recommendations from sysward.com (2026) and OWASP Docker Security Cheat Sheet are fully implementable within this structure

## Diagram

```mermaid
flowchart TD
    A[site.yml] --> B[essentials role]
    A --> C[zsh role]
    A --> D[hardening role]
    A --> E[docker role]
    A --> F[podman role]
    A --> G[jenkins role]
    A --> H[nginx role]
    A --> I[cloud roles]
    A --> J[orchestrator roles]
    A --> K[packer/terraform]

    D --> D1[SSH hardening]
    D --> D2[Firewall/UFW]
    D --> D3[Password policy]
    D --> D4[Fail2Ban]
    D --> D5[Kernel sysctl]       # NEW
    D --> D6[Filesystem lockdown] # NEW
    D --> D7[Logging/auditd]      # ENHANCED
    D --> D8[Resource limits]     # NEW

    H --> H1[Reverse proxy]
    H --> H2[TLS/SSL]             # NEW
    H --> H3[Security headers]    # NEW

    G --> G1[Jenkins install]
    G --> G2[Plugin management]
    G --> G3[Secure output]       # FIXED
```

## Consequences

### Positive
- CIS Level 1 baseline compliance for Ubuntu Linux server
- OWASP Docker Security Rule #6 compliance (seccomp/AppArmor)
- Jenkins admin credentials no longer exposed in Ansible output
- NGINX reverse proxy secured with TLS and security headers
- Centralized logging configuration with resource limits
- Kernel-level network attack mitigations enabled
- All changes are idempotent and safely repeatable

### Negative / Accepted technical debt
- Hardening role `tasks/main.yml` grows to ~400 lines (manageable with clear section comments)
- Self-signed TLS certificate for NGINX (acceptable for dev; production should use Let's Encrypt)
- No automated container image scanning in CI/CD pipeline (out of scope for now)
- No multi-factor authentication for Jenkins (requires plugin, deferred)

### Identified risks
- [RISK] Kernel sysctl changes may affect Docker networking (mitigation: `ip_forward` kept at 1 for containers)
- [RISK] `MaxAuthTries 3` could lock out legitimate users (mitigation: combined with Fail2Ban, `3` per connection is standard)
- [RISK] Disabling filesystem modules may break legacy apps (mitigation: only unused/legacy modules blacklisted)

## Follow-up actions

- [ ] Implement sysctl kernel hardening parameters — Owner: @build — Date: 2026-05-01
- [ ] Implement filesystem module blacklisting — Owner: @build — Date: 2026-05-01
- [ ] Add auditd rules and journald configuration — Owner: @build — Date: 2026-05-01
- [ ] Configure NGINX TLS and security headers — Owner: @build — Date: 2026-05-01
- [ ] Fix Jenkins secret exposure with no_log — Owner: @build — Date: 2026-05-01
- [ ] Add .gitignore and vault configuration — Owner: @build — Date: 2026-05-01
- [ ] Enable host_key_checking in ansible.cfg — Owner: @build — Date: 2026-05-01

## References

- CIS Ubuntu Linux 24.04 LTS Benchmark, Level 1 — https://www.cisecurity.org/benchmark/ubuntu_linux
- SysWard Linux Server Hardening Checklist (2026) — https://sysward.com/blog/2026-05-06-linux-server-hardening-checklist/
- OWASP Docker Security Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html
- Red Hat Ansible Automation Platform Hardening Guide 2.4 — https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.4/
- Docker Rootless Mode — https://docs.docker.com/engine/security/rootless/
- Ansible Vault Documentation — https://docs.ansible.com/ansible/latest/vault_guide/vault.html
