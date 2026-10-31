# Replication: Sequential Sampling by Individuals and Groups: An Experimental Study

Pellumb Reshidi, Alessandro Lizzeri, Leeat Yariv, Jimmy Chan, and Wing Suen — *AEA Data and Code Repository, V1 (2025)*.

This [stats.camp](https://stats.camp) repository preserves official AEA deposit
**208222, version V1**, for replication and engine compatibility testing.
**Status: executed on 2026-10-16 and again on 2026-10-17 with the native stats.camp engine from scratch copies; the package runs end to end.** The analysis do-files retain their original commands, paths, whitespace, encoding, and line endings.

## The study

Compares individuals and groups collecting costly information before making decisions, with majority and unanimity voting rules in a laboratory experiment.

## Contents and entry points

The deposit includes three analysis datasets, four Excel inputs, three analysis scripts, participant instruction slides, and the original oTree software ZIP. The software ZIP is retained as an original file and has not been unpacked or executed.

The original archive contains **15 original files** totaling
**69,895,125 bytes**. The source ZIP is
17,908,543 bytes. Research data and code are retained. Accompanying notes are adapted for stats.camp;
source documentation and preparation records are maintained separately.

Entry points for inspection:

- [Replication Package/Replication Package/do files/analysis.do](Replication%20Package/Replication%20Package/do%20files/analysis.do)
- [Replication Package/Replication Package/do files/analysis_online_appendix.do](Replication%20Package/Replication%20Package/do%20files/analysis_online_appendix.do)
- [Replication Package/Replication Package/do files/data_cleaning.do](Replication%20Package/Replication%20Package/do%20files/data_cleaning.do)

Package documentation adapted for stats.camp:

- [Replication Package/Replication Package/REPLICATION.txt](Replication%20Package/Replication%20Package/REPLICATION.txt)

## Setup and current scope

Both `Replication Package/` wrapper directories are retained exactly as deposited. The scripts repeatedly switch to absolute Windows `data` and `output` directories; these remain unchanged. The README identifies `analysis.do` and `analysis_online_appendix.do` as the main and appendix entry points and requires `estout` and `cdfplot`.

The 2026-10-16 runs used scratch copies, so the figures, logs and intermediate
datasets in this repository are still the authors' deposited reference material.

## Inspect in stats.camp

These links open the deposited files for inspection. They do not establish
that the preserved paths, dependencies, or commands are executable in the browser.

- [Replication Package/Replication Package/do files/analysis.do](https://stats.camp/app?open=https%3A%2F%2Fgithub.com%2Fstats-camp%2Freplication-sequential-sampling.git&file=Replication%20Package%2FReplication%20Package%2Fdo%20files%2Fanalysis.do)
- [Replication Package/Replication Package/do files/analysis_online_appendix.do](https://stats.camp/app?open=https%3A%2F%2Fgithub.com%2Fstats-camp%2Freplication-sequential-sampling.git&file=Replication%20Package%2FReplication%20Package%2Fdo%20files%2Fanalysis_online_appendix.do)
- [Replication Package/Replication Package/do files/data_cleaning.do](https://stats.camp/app?open=https%3A%2F%2Fgithub.com%2Fstats-camp%2Freplication-sequential-sampling.git&file=Replication%20Package%2FReplication%20Package%2Fdo%20files%2Fdata_cleaning.do)

## Source integrity and attribution

- [Official deposit](https://www.openicpsr.org/openicpsr/project/208222/version/V1/view)
- [Deposit DOI](https://doi.org/10.3886/E208222V1)

Archive: `208222-V1.zip`. SHA-256:
`f4f20d90b31969d4d35e41e73e07868ad3ed113332451d183ef8e8d10f934d5a`.

All original file hashes were checked after extraction. `.gitattributes` disables
Git line-ending normalization to preserve deposited bytes. Empty folders are
represented by `.gitkeep` files. The root README and Git attributes are stats-camp additions.

The archive contains no separate LICENSE file. The authors’ rights and provenance statements are retained in the adapted notes; this mirror does not add a license or replace those terms.

The study, code, and data remain credited to Pellumb Reshidi, Alessandro Lizzeri, Leeat Yariv, Jimmy Chan, and Wing Suen; stats-camp maintains
this mirror and its preparation documentation.
