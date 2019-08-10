# purebred-icu

A library adding support for many more charsets to the purebred MUA.
It uses the /text-icu/ library (and /libicu/ under the hood) to
convert text.

## Enabling during development

After you've cloned
[purebred](https://github.com/purebred-mua/purebred) and purebred-icu,
you can use a [ cabal project file
](https://www.haskell.org/cabal/users-guide/nix-local-build.html?highlight=project#cfg-field-packages):


    # clone purebred-icu as well into an adjacent directory to purebred
    # and make cabal aware of purebred *and* purebred-icu necessary to build
    echo "packages: .,../purebred-icu" > cabal.project.local

    # install purebred and the purebred-icu plugin
    $ cabal --enable-nix new-install --overwrite-policy=always exe:purebred lib:purebred-icu

To run purebred enable the plugin in the config:

```Haskell
import Purebred
import qualified Purebred.Plugin.ICU

main :: IO ()
main = purebred $ tweak defaultConfig where
  tweak = Purebred.Plugin.ICU.enable
```

Then run purebred:

    $ ~/.cabal/bin/purebred