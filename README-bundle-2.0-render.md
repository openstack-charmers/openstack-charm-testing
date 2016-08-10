render2.sh
=========================================================================
Renders one or more Juju 2 bundles from an old-style multiple-inheritance
bundle.  The source bundle must use "charm: cs:foo" (not branch: foo).

New or updated bundles will be written to a "rendered" subdir,
overwriting any existing files.  The rendered bundle files should not
be hand-edited, as those changes may be lost by future renders.  Any
necessary changes should be maintained in the classic source bundle.

### Example: Render the default set Ubuntu-OpenStack combos
```
./tools/render2.sh bundles/ppc64/ppc64el-next.yaml
```

### Example: Render specific combos
```
./tools/render2.sh bundles/ppc64/ppc64el-next.yaml "trusty-kilo xenial-mitaka"
```
