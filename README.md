This repository demonstrates an issue encountered when using (at least some) global constraints [libminizinc v2.6.4](https://github.com/MiniZinc/libminizinc/tree/2.6.4) and [chuffed v0.10.4](https://github.com/chuffed/chuffed) with the default installation paths/options.

To recreate the issue, you can clone this repository (with submodules) and run `docker compose build && docker compose run minizinc` (or, if you like, use the corresponding non-compose commands). It will fail with [this error message](https://github.com/ReubenJ/minizinc-chuffed-fix/blob/154fcbfa0c06b9978bfd0bfdd3fdebfa97777eb1/error-msg.txt).

The fixes have actually been merged to the `develop` branch of chuffed, they just haven't been merged and released.