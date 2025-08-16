{
  description = ''
    NixOS config by hcw
  '';
  nixConfig.license = "BSD-3-Clause";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05"; 
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; 
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #hyprspace = { url = "github:KZDKM/Hyprspace"; }; # fork
    #hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # fork
    #hyprpolkitagent.url = "github:hyprwm/hyprpolkitagent"; # fork
    #hyprpanel.url = "github:Jas-SinghFSU/HyprPanel"; # fork
    stylix.url = "github:danth/stylix/release-24.05"; # fork

    # atticd
    #attic = {
      #url = "github:zhaofengli/attic";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};


    # ANCHORED COMMIT
    sops-nix = {
      url = "github:hcw9iu/sops-nix"; # fork
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprspace = { 
      #type = "git";
      #url = "git+ssh://git@github.com/hcw9iu/Hyprspace"; 
      url = "github:hcw9iu/Hyprspace"; 
      #ref = "main";
      }; 
    #hyprland = {
      #type = "git";
      #url = "git+ssh://git@github.com/hcw9iu/Hyprland";
      #submodules = true;
      #ref = "main";
      #allRefs = true;
    #};
    hyprland.url = "github:hcw9iu/Hyprland?submodules=1";
    hyprpolkitagent = {
      #type = "git";
      #url = "git+ssh://git@github.com/hcw9iu/hyprpolkitagent";
      url = "github:hcw9iu/hyprpolkitagent";
      #ref = "main";
      #allRefs = true;
    };
    hyprpanel = {
      #type = "git";
      #url = "git+ssh://git@github.com/hcw9iu/HyprPanel";
      url = "github:hcw9iu/Hyprpanel/10ac1fbf27e6a06329ef4279846a4aaadf7e332b"
      #ref = "main"; 
      #rev = "10ac1fbf27e6a06329ef4279846a4aaadf7e332b";
      #allRefs = true;
    };
    #stylix.url = "github:hcw9iu/stylix"; 

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix"; 
  
    zen-browser.url =
      "git+https://git.sr.ht/~canasta/zen-browser-flake/"; 
    
    wallpapers = {
      url = "github:anotherhadi/nixy-wallpapers"; # overwrite
      flake = false;
    };
    #cursor.url = "github:hcw9iu/cursor-flake/main?ssh=yes"; # overwrite, private repo
    #cursor = {
      #type = "git";
      #url = "git+ssh://git@github.com/hcw9iu/cursor-flake";
      #ref = "main";
      #allRefs = true;
    #};
    #atticConf = {
      #url = "path:/BD/cache/config";
      #flake = false;
    #};
  };

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations = {
      nixos = # CHANGEME: This should match the 'hostname' in your variables.nix file
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          #specialArgs = { inherit inputs; }; # for attic
          modules = [
            {
              nixpkgs.overlays = [ 
                inputs.hyprpanel.overlay 
                inputs.nur.overlays.default
                #inputs.attic.overlays.default # for attic 
              ];
              _module.args = { inherit inputs; };
            }  
            #({ pkgs, inputs, ... }: {
              #environment.systemPackages = [ 
                ##pkgs.attic 
                #inputs.attic.packages.${pkgs.system}.attic # for attic
              #];
            #})
            #({ pkgs, ... }: {
              #environment.systemPackages = [
              #cursor.packages.${pkgs.system}.default
              #];
              ##boot.kernelPackages = pkgs.linuxPackages_6_12;
            #})
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
            #inputs.pia.nixosModules."x86_64-linux".default
            ./hosts/desktop/configuration.nix # CHANGEME: change the path to match your host folder
          ];
        };
    };
  };
}
