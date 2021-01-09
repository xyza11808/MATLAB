# -*- coding: utf-8 -*-
"""
Created on Wed Oct 16 17:24:12 2019

@author: Libra
"""

import numpy as np
# import phylib.utils._misc as phyutil
import pandas as pd
import h5py
import matplotlib.pyplot as plt
import matplotlib

FR_Th = 1.0


def trialAlign(trials, oneTS):
    oneTS = oneTS[
        np.bitwise_and(
            oneTS >= trials[0, 0] - 30000 * 5, oneTS <= (trials[-1, 0] + 30000 * 10)
        )
    ]  # only the performing period
    TSidx = 0
    trial_index = 0
    trial_id = np.ones_like(oneTS)
    while TSidx < len(oneTS) and trial_index < len(trials):
        if oneTS[TSidx] < trials[trial_index, 0] + (trials[trial_index, 7] + 8) * 30000:
            oneTS[TSidx] -= trials[trial_index, 0]
            trial_id[TSidx] = trial_index
            TSidx += 1
        else:
            trial_index += 1
    return (oneTS, trial_id)


def baselineVector(oneTS, trial_id, trials, SU_id):
    tIdices = range(trials.shape[0])
    base = []
    for trial_index in tIdices:
        for binCount in np.histogram(
            oneTS[trial_id == trial_index], bins=4, range=(-60000, -30000)
        )[0]:
            base.append(binCount)
    if len(base) > 0 and np.std(base):
        return (np.mean(base), np.std(base))
    # breakpoint()
    print("Error calculating base vector unit#%d" % (SU_id,))
    return (0, 32767)


def toHist(trials, oneTS, trial_id, sample, delay):
    sel = np.nonzero(np.bitwise_and(trials[:, 4] == sample, trials[:, 7] == delay))[0]
    return (
        np.histogram(
            oneTS[np.isin(trial_id, sel)],
            np.linspace(-60000, 30000 * (delay + 6), num=(delay + 8) * 4 + 1),
        )[0]
    ) / len(sel)


def toHistByPair(trials, oneTS, trial_id, isPaired, delay):
    if isPaired:
        sel = np.nonzero(
            np.bitwise_and(trials[:, 4] != trials[:, 5], trials[:, 7] == delay)
        )[0]
    else:
        sel = np.nonzero(
            np.bitwise_and(trials[:, 4] == trials[:, 5], trials[:, 7] == delay)
        )[0]
    return (
        (
            np.histogram(
                oneTS[np.isin(trial_id, sel)],
                np.linspace((delay - 1) * 30000, (delay + 6) * 30000, num=7 * 4 + 1),
            )[0]
        ),
        len(sel),
    )


def alignHeatmap(spkTS, spkCluster, unitInfo, trials):
    # bySample43 = []
    bySample46 = []
    # bySample83 = []
    bySample86 = []

    paired = []
    nonpaired = []

    baseVecAll = []
    depth = []
    s1s = 30000
    spkNThresh = spkTS[-1] / s1s * FR_Th

    for SU_id in unitInfo.index:
        # breakpoint()
        wf = unitInfo.loc[SU_id].get("group") == "good" or (
            np.isnan(unitInfo.loc[SU_id]['group'])
            and unitInfo.loc[SU_id]["KSLabel"] == "good"
        )
        spkCount = unitInfo.loc[SU_id]["n_spikes"]
        if spkCount > spkNThresh and wf:
            oneTSAll = (spkTS[spkCluster == SU_id]).astype(
                "int64"
            )  # oneTSAll, all time stamp of a SU
            (oneTS, trial_id) = trialAlign(trials, oneTSAll)
            baseVec = baselineVector(oneTS, trial_id, trials, SU_id)
            baseVecAll.append(baseVec)
            # bySample43.append(toHist(trials, oneTS, trial_id, 4, 3))
            bySample46.append(toHist(trials, oneTS, trial_id, 4, 6))
            # bySample83.append(toHist(trials, oneTS, trial_id, 8, 3))
            bySample86.append(toHist(trials, oneTS, trial_id, 8, 6))
            # (p3, t3) = toHistByPair(trials, oneTS, trial_id, True, 3)
            (p6, t6) = toHistByPair(trials, oneTS, trial_id, True, 6)
            paired.append(np.array(p6) / t6)
            # paired.append((np.array(p3) + np.array(p6)) / (t3 + t6))

            # (n3, tn3) = toHistByPair(trials, oneTS, trial_id, False, 3)
            (n6, tn6) = toHistByPair(trials, oneTS, trial_id, False, 6)
            nonpaired.append( np.array(n6) / tn6)
            # nonpaired.append((np.array(n3) + np.array(n6)) / (tn3 + tn6))

            depth.append(unitInfo.loc[SU_id]["depth"])

    depth = np.array(depth)
    if depth.shape[0] > 0:
        baseVecAll = np.array(baseVecAll)
        dIdx = np.argsort(depth)
        # bySample43 = np.array(bySample43)
        bySample46 = np.array(bySample46)
        # by1Sample83 = np.array(bySample83)
        bySample86 = np.array(bySample86)
        paired = np.array(paired)
        nonpaired = np.array(nonpaired)
        return (
            (
                # bySample43[dIdx, :],
                bySample46[dIdx, :],
                # bySample83[dIdx, :],
                bySample86[dIdx, :],
            ),
            (paired[dIdx, :], nonpaired[dIdx, :]),
            baseVecAll[dIdx],
            depth[dIdx],
        )
    else:
        return ([], [], [], [])


def plotOne(data, delay, ax, ylbl):

    im = plt.imshow(data, cmap="jet", aspect="auto", vmin=-3, vmax=3)

    if delay == 6:
        [
            plt.plot([x, x], ax.get_ylim(), "-w")
            for x in np.array([2, 3, 9, 10]) * 4 - 0.5
        ]
        ax.set_xticks(np.array([2, 7, 12]) * 4 - 0.5)
        ax.set_xticklabels([0, 5, 10])
    #        ax.set_xlabel('Time (s)')

    elif delay == 3:
        [
            plt.plot([x, x], ax.get_ylim(), "-w")
            for x in np.array([2, 3, 6, 7]) * 4 - 0.5
        ]
        ax.set_xticks(np.array([2, 7]) * 4 - 0.5)
        ax.set_xticklabels([0, 5])

    if ylbl:
        ax.set_ylabel("Unit #")
    return im


def plotOneSel(A, B, delay, ax, ylbl):

    plt.imshow((B - A) / (B + A), cmap="jet", aspect="auto", vmin=-1, vmax=1)

    #    if delay==6:
    #        [plt.plot([x,x],ax.get_ylim(),'-w') for x in np.array([2,3,9,10])*4-0.5]
    #        ax.set_xticks(np.array([2,7,12])*4-0.5)
    #        ax.set_xticklabels([0,5,10])
    #
    #
    #    elif delay==3:
    #        [plt.plot([x,x],ax.get_ylim(),'-w') for x in np.array([2,3,6,7])*4-0.5]
    #        ax.set_xticks(np.array([2,7])*4-0.5)
    #        ax.set_xticklabels([0,5])
    [plt.plot([x, x], ax.get_ylim(), "-w") for x in np.array([2, 3]) * 4 - 0.5]
    ax.set_xticks(np.array([2, 6]) * 4 - 0.5)
    ax.set_xticklabels(["S+0", "S+4"])

    if ylbl:
        ax.set_ylabel("Unit #")

    ax.set_xlabel("Time (s)")


def plotOneSelByPair(A, B, ax):

    im = plt.imshow((B - A) / (B + A), cmap="jet", aspect="auto", vmin=-1, vmax=1)

    [plt.plot([x, x], ax.get_ylim(), "-w") for x in np.array([2, 3]) * 4 - 0.5]
    ax.set_xticks(np.array([2, 7]) * 4 - 0.5)
    ax.set_xticklabels(["T+0", "T+5"])

    ax.set_xlabel("Time (s)")
    return im


def plotBehavior(trials, ax):
    correct = np.logical_xor(trials[:, 4] == trials[:, 5], trials[:, 6] == 1)
    licks = trials[:, 6] == 1
    perf = []
    lickPct = []
    for ubound in range(16, len(correct), 16):
        perf.append(np.mean(correct[ubound - 16 : ubound]))
        lickPct.append(np.mean(licks[ubound - 16 : ubound]))
    plt.plot(perf, "-k", label="correct rate")
    plt.plot(lickPct, "--r", label="lick rate")
    ax.legend()
    ax.set_ylim(0, 1.0)
    ax.set_ylabel("correct rate, lick rate")
    ax.set_xlabel("block of 16 trials")
    ax.set_title("behavior performance")


def plotHeatmap(trials, raw, byPaired, base, depth):
    import os

    cwd = os.getcwd()
    leafPath = os.path.split(cwd)[1]
    fh = plt.figure(3, figsize=[8, 10])

    # ax = plt.subplot(3, 3, 1)
    # plotOne(((raw[0].transpose() - base[:, 0]) / base[:, 1]).transpose(), 3, ax, True)
    # ax.set_title("S1 3s delay")
    # ax = plt.subplot(3, 3, 2)
    # im = plotOne(
    #     ((raw[2].transpose() - base[:, 0]) / base[:, 1]).transpose(), 3, ax, False
    # )
    # plt.colorbar(im, ticks=[-3, 0, 3], format="%d")
    # ax.set_title("S2 3s delay")

    ax = plt.subplot(3, 3, 1)
    plotOne(((raw[0].transpose() - base[:, 0]) / base[:, 1]).transpose(), 6, ax, True)
    ax.set_title("S1 6s delay")
    ax = plt.subplot(3, 3, 2)
    im = plotOne(
        ((raw[1].transpose() - base[:, 0]) / base[:, 1]).transpose(), 6, ax, False
    )
    plt.colorbar(im, ticks=[-3, 0, 3], format="%d")
    ax.set_title("S2 6s delay")

    # depth plot
    ax = plt.subplot(3, 3, 6)
    plt.plot(depth)
    ax.set_ylabel("distance from tip (um)")
    ax.set_xlabel("unit #")
    plt.minorticks_on()
    plt.grid(b=True, which="both")

    ax = plt.subplot(3, 3, 4)
    im = plotOneSel(
        raw[0][:, 0:24], raw[1][:, 0:24],
        # raw[0][:, 0:24] + raw[1][:, 0:24],
        # raw[2][:, 0:24] + raw[3][:, 0:24],
        6,
        ax,
        False,
    )
    ax.set_title("sample selectivity")
    #    plt.colorbar(im,ticks=[-1,0,1],format='%d')

    ax = plt.subplot(3, 3, 5)
    im = plotOneSelByPair(byPaired[0], byPaired[1], ax)
    ax.set_title("pair/non-pair selectivity")
    plt.colorbar(im, ticks=[-1, 0, 1], format="%d")

    ax = plt.subplot(3, 3, 3)
    plotBehavior(trials, ax)

    fh.suptitle(leafPath.replace("_cleaned", ""))
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    #plt.show()

    # breakpoint()
    fh.savefig(leafPath.replace("_cleaned", "") + ".png", dpi=300, bbox_inches="tight")
    # matplotlib.rcParams['pdf.fonttype'] = 42
    # matplotlib.rcParams['ps.fonttype'] = 42
    # fh.savefig(leafPath.replace("_cleaned", "") + ".pdf", dpi=300, bbox_inches="tight")
    plt.close("all")


#    return (fh,ax)


def runParse():
    #    s1s=30000
    spkTS = np.load("spike_times.npy")
    spkCluster = np.load("spike_clusters.npy")

    unitInfo = pd.read_csv("cluster_info.tsv",sep='\t',index_col='id')

    trials = np.empty([0])
    with h5py.File("events.hdf5", "r") as fe:
        dset = fe["trials"]
        trials = np.array(dset, dtype="int32")
        events=fe['events']
    (raw, byPaired, baseVec, depth) = alignHeatmap(spkTS, spkCluster, unitInfo, trials)
    if raw and byPaired:
        plotHeatmap(trials, raw, byPaired, baseVec, depth)
    else:
        print("empty SU list\n")


if __name__ == "__main__":
    #    import os
    #    os.chdir('K:/neupix/191015-DPA-Learning2_29_g0_imec0_cleaned')
    #
    s1s = 30000
    spkTS = np.load("spike_times.npy")
    spkCluster = np.load("spike_clusters.npy")

    unitInfo = pd.read_csv("cluster_info.tsv",sep='\s+',index_col='id')

    trials = np.empty([0])
    with h5py.File("events.hdf5", "r") as fe:
        dset = fe["trials"]
        trials = np.array(dset, dtype="int64")
    (raw, byPaired, baseVec, depth) = alignHeatmap(spkTS, spkCluster, unitInfo, trials)
    if byPaired.size > 0:
        plotHeatmap(trials, raw, byPaired, baseVec, depth)
    else:
        print("empty SU list\n")
