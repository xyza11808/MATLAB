# -*- coding: utf-8 -*-
"""
Created on Wed Oct 23 09:25:13 2019

@author: Libra
"""

import phy.apps.template.gui as phygui
from phylib.io.model import get_template_params


def phyProcess(params_path, **kwargs):
    controller = phygui.TemplateController(**get_template_params(params_path), **kwargs)
    controller._save_cluster_info()
    controller.model.close()


def runPhy():
    phyProcess("params.py")


if __name__ == "__main__":
    phyProcess("params.py")
