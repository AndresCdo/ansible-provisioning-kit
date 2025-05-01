# Infrastructure Automation with Ansible

This repository contains Ansible playbooks and roles designed for setting up and managing a development or infrastructure environment. It leverages various roles to install and configure essential tools, container runtimes (Docker, Podman), orchestration tools (Minikube, MicroK8s), CI/CD (Jenkins), cloud CLIs (AWS, Google Cloud), Infrastructure as Code tools (Terraform, Packer), and common utilities.

## Structure

The repository follows a standard Ansible project structure:

- `ansible.cfg`: Ansible configuration file (defines inventory path, roles path, etc.).
- `inventory/`: Contains inventory files.
  - `hosts.yml`: Defines hosts and groups (using YAML format).
- `playbooks/`: Contains the main playbooks.
  - `site.yml`: The primary playbook that applies roles to hosts defined in the inventory.
- `group_vars/`: Contains variables applicable to host groups.
  - `all.yml`: Variables applied to all hosts.
- `host_vars/`: Contains variables specific to individual hosts (e.g., `hostname.yml`).
- `roles/`: Directory containing all the roles used in the playbook.
  - `aws_cli/`: Role for setting up AWS CLI.
  - `common/`: (Placeholder - intended for common tasks/packages across roles).
  - `docker/`: Role for installing and configuring Docker and Docker Compose.
  - `essentials/`: Role for installing essential base packages (vim, curl, build-essential).
  - `google_sdk/`: Role for setting up Google Cloud SDK.
  - `hardening/`: Role for applying basic security hardening (e.g., UFW setup).
  - `jenkins/`: Role for installing and configuring Jenkins.
  - `microk8s/`: Role for installing MicroK8s.
  - `minikube/`: Role for installing Minikube.
  - `nginx/`: Role for installing and configuring Nginx (e.g., as a reverse proxy for Jenkins).
  - `packer/`: Role for installing HashiCorp Packer.
  - `podman/`: Role for installing Podman.
  - `terraform/`: Role for installing HashiCorp Terraform.
  - `zsh/`: Role for installing Zsh and Oh-My-Zsh.
- `files/`: Global files used by playbooks/roles (prefer role-specific `files/`).
- `templates/`: Global templates used by playbooks/roles (prefer role-specific `templates/`).
- `README.md`: This file.

Each role directory typically contains:

- `tasks/main.yml`: Main tasks for the role.
- `handlers/main.yml`: Handlers triggered by tasks.
- `defaults/main.yml`: Default variables for the role (lowest precedence).
- `vars/main.yml`: Variables for the role (higher precedence than defaults).
- `files/`: Files to be copied to the target hosts.
- `templates/`: Templates (usually Jinja2) to be rendered and deployed.

## Usage

1. **Prerequisites:** Ensure Ansible is installed on your control machine.
2. **Inventory:** Review and update `inventory/hosts.yml` to define the target hosts and connection details (e.g., `ansible_user`, `ansible_host`). For local execution, the default `localhost` with `ansible_connection: local` might suffice.
3. **Run Playbook:** Execute the main playbook:

    ```bash
    ansible-playbook playbooks/site.yml
    ```

    Ansible will use the `ansible.cfg` file to find the inventory and roles automatically.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for suggestions or improvements.

## License

This project is licensed under the MIT License.
