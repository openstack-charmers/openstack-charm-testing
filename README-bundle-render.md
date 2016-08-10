render2.sh
===========================================================================
Renders one or more Juju 1+2 bundles from an old-style multiple-inheritance
bundle.  The source bundle must use "charm: cs:foo" (not branch: foo).

New or updated bundles will be written to a "rendered" subdir,
overwriting any existing files.  The rendered bundle files should not
be hand-edited, as those changes may be lost by future renders.  Any
necessary changes should be maintained in the classic source bundle.

### Example: Render the default set of Ubuntu-OpenStack targets
```
./tools/render2.sh bundles/ppc64/ppc64el-next.yaml
```

### Example: Render the default set of targets from all source bundles in a dir
```
./tools/render2.sh bundles/ppc64/*.yaml
```

### Example: Render specific targets from a single source bundle
```
./tools/render2.sh -t "trusty-kilo xenial-mitaka" bundles/ppc64/ppc64el-next.yaml
```

### Example: Render specific targets from all source bundles in a dir
```
./tools/render2.sh -t "trusty-kilo xenial-mitaka" bundles/ppc64/*.yaml
```
