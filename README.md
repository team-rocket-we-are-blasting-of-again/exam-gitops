# IAC

## Environment information

### Root

The root terraform config sets up all providers and creates the kubernetes cluster

### Modules

Consists of reusable terraform modules

### Environments

All separate environments, this will be things such as devops, test, staging, and prod

They are separated using namespaces, and will be prioritized through the PriorityClass kubernetes kind.

### Scripts

Provides scripts to allow running scripts in all terraform modules.
Example:

```bash
sh scripts/execute.sh validate
```

This will run the validate.sh script in all modules.
