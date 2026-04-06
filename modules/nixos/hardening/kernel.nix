_: {
  boot.kernelParams = [
    # make it harder to influence slab cache layout
    "slab_nomerge"
    # enables zeroing of memory during allocation and free time
    # helps mitigate use-after-free vulnerabilities
    "init_on_alloc=1"
    "init_on_free=1"
    # randomizes page allocator freelist, improving security by
    # making page allocations less predictable
    "page_alloc.shuffle=1"
    # enables Kernel Page Table Isolation, which mitigates Meltdown and
    # prevents some KASLR bypasses
    "pti=on"
    # randomizes the kernel stack offset on each syscall
    # making attacks that rely on a deterministic stack layout difficult
    "randomize_kstack_offset=on"
    # disables vsyscalls, they've been replaced with vDSO
    "vsyscall=none"
    # disables debugfs, which exposes sensitive info about the kernel
    "debugfs=off"
    # only allows kernel modules that have been signed with a valid key to be loaded
    # making it harder to load malicious kernel modules
    "module.sig_enforce=1"
    # prevents user space code escalation
    "lockdown=confidentiality"
  ];

  security = {
    lsm = [
      "landlock"
      "lockdown"
      "yama"
      "bpf"
    ];
    protectKernelImage = true;
    allowUserNamespaces = true;
    allowSimultaneousMultithreading = true;
  };
}
