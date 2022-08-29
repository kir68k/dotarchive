# TODO list for the dotfiles repo

### Todo
- [ ] Better handling of `isolcpus` (`config.ki.virtualisation.libvirt.isolateCpus`)
    - Currently this is pretty imperative, it's used for my Windows 10 VM to which I delegate 4 logical cores, isolating them.

- [ ] Migrate server config here
    - Currently the server config resides on a different repo, with a way different structure and foundation. It is less flexible and harder to change than this one.

- [ ] Better handling of user groups
    - In `flake.nix` there's a quite long list of user groups, under line 219 (As of commit 9fd276).
    - From one side, I think I should change the way this works, but from another side NixOS won't add you to any of those groups if they don't exist, they aren't made automatically, but by their respective service... because of that, I think it's also okay to leave it the way this is.

- [ ] Implement Tmux plugin option
    - Current tmux module is pretty basic, excluding the usage of tmux plugins. Not that I use any rn, but would be nice to implement.
