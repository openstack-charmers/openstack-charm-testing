#!/usr/bin/make

render: render-ppc64 render-metal render-sparse render-multihv render-dfs

render-ppc64:
	@./tools/render2.sh bundles/ppc64/*yaml

render-metal:
# Not enabled yet, pending bundle edits for cs:foo
#	@./tools/render2.sh bundles/baremetal/*yaml

render-sparse:
# Not enabled yet, pending bundle edits for cs:foo
#	@./tools/render2.sh bundles/sparse/*yaml

render-multihv:
# Not enabled yet, pending bundle edits for cs:foo
#	@./tools/render2.sh bundles/multi-hypervisor/*yaml

render-lxd:
# Not enabled yet, pending bundle edits for cs:foo
#	@./tools/render2.sh bundles/lxd/*yaml
#	@./tools/render2.sh bundles/lxd/source/default.yaml
#	@./tools/render2.sh bundles/lxd/source/next.yaml

render-dfs:
# Not enabled yet, pending bundle edits for cs:foo
#	@./tools/render2.sh bundles/source/default.yaml
#	@./tools/render2.sh bundles/source/next.yaml
#	@./tools/render2.sh bundles/source/next-defaults.yaml

