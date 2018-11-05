use Mix.Releases.Config,
  default_release: :example,
  default_environment: Mix.env()

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"r`O5^:4.FL=Fu?ujvplK25TMlOJXUtj]=S,|6&]MW<ap||$qh*@o_{GT$/]@?HNj")
  set(vm_args: "rel/etc/prod.vm.args")
  set(pre_configure_hooks: "rel/hooks/pre_configure")

  set(
    overlays: [
      {:copy, "rel/etc/example.service", "etc/example.service"}
    ]
  )
end

release :example do
  set(version: current_version(:example))

  set(
    applications: [
      :runtime_tools,
      :example
    ]
  )
end
