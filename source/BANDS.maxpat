{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 6,
      "revision": 5,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      80.0,
      100.0,
      1120.0,
      169.0
    ],
    "openrect": [
      0.0,
      0.0,
      1120.0,
      169.0
    ],
    "openinpresentation": 1,
    "default_fontsize": 11.0,
    "default_fontname": "Arial",
    "bgcolor": [
      0.065,
      0.085,
      0.105,
      1.0
    ],
    "bglocked": 1,
    "boxes": [
      {
        "box": {
          "id": "in",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            30,
            220,
            250,
            22
          ],
          "text": "plugin~"
        }
      },
      {
        "box": {
          "id": "out",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            220,
            250,
            22
          ],
          "text": "plugout~"
        }
      },
      {
        "box": {
          "id": "control",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            590,
            220,
            250,
            22
          ],
          "text": "js bands_control.js ---bands"
        }
      },
      {
        "box": {
          "id": "viewbus",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            220,
            250,
            22
          ],
          "text": "r ---bands-view"
        }
      },
      {
        "box": {
          "id": "cmd",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            220,
            250,
            22
          ],
          "text": "r ---bands-command"
        }
      },
      {
        "box": {
          "id": "view",
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            0,
            0,
            530,
            143
          ],
          "presentation": 1,
          "presentation_rect": [
            0,
            0,
            530,
            143
          ],
          "filename": "bands_view.js",
          "jsarguments": [
            "---bands",
            0
          ],
          "parameter_enable": 0,
          "border": 0
        }
      },
      {
        "box": {
          "id": "clock",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            220,
            250,
            22
          ],
          "text": "qmetro 33"
        }
      },
      {
        "box": {
          "id": "clockon",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            285,
            250,
            22
          ],
          "text": "loadmess 1"
        }
      },
      {
        "box": {
          "id": "dev",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            310,
            285,
            250,
            22
          ],
          "text": "live.thisdevice"
        }
      },
      {
        "box": {
          "id": "defer",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            285,
            250,
            22
          ],
          "text": "deferlow"
        }
      },
      {
        "box": {
          "id": "init",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            870,
            285,
            250,
            22
          ],
          "text": "t b b"
        }
      },
      {
        "box": {
          "id": "initmsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            285,
            250,
            22
          ],
          "text": "prepend init"
        }
      },
      {
        "box": {
          "id": "load",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            285,
            250,
            22
          ],
          "text": "loadbang"
        }
      },
      {
        "box": {
          "id": "loaddefer",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            350,
            250,
            22
          ],
          "text": "deferlow"
        }
      },
      {
        "box": {
          "id": "dsp",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 6,
          "patching_rect": [
            310,
            350,
            250,
            22
          ],
          "text": "dspstate~"
        }
      },
      {
        "box": {
          "id": "sr",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            350,
            250,
            22
          ],
          "text": "prepend samplerate"
        }
      },
      {
        "box": {
          "id": "splits",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            12,
            146,
            65,
            18
          ],
          "text": "SPLITS / Hz",
          "presentation": 1,
          "presentation_rect": [
            12,
            146,
            65,
            18
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "splits",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "edge0",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            80,
            146,
            76,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            80,
            146,
            76,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 1",
              "parameter_shortname": "Split 1",
              "parameter_type": 0,
              "parameter_mmin": 15.0,
              "parameter_mmax": 49.0,
              "parameter_initial": [
                30.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            350,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            350,
            250,
            22
          ],
          "text": "line 30. 10"
        }
      },
      {
        "box": {
          "id": "fmsg0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            350,
            250,
            22
          ],
          "text": "prepend crossover 0"
        }
      },
      {
        "box": {
          "id": "edge1",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            165,
            146,
            76,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            165,
            146,
            76,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 2",
              "parameter_shortname": "Split 2",
              "parameter_type": 0,
              "parameter_mmin": 50.0,
              "parameter_mmax": 139.0,
              "parameter_initial": [
                80.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            415,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            415,
            250,
            22
          ],
          "text": "line 80. 10"
        }
      },
      {
        "box": {
          "id": "fmsg1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            415,
            250,
            22
          ],
          "text": "prepend crossover 1"
        }
      },
      {
        "box": {
          "id": "edge2",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            250,
            146,
            76,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            250,
            146,
            76,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 3",
              "parameter_shortname": "Split 3",
              "parameter_type": 0,
              "parameter_mmin": 140.0,
              "parameter_mmax": 599.0,
              "parameter_initial": [
                250.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            415,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            415,
            250,
            22
          ],
          "text": "line 250. 10"
        }
      },
      {
        "box": {
          "id": "fmsg2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            415,
            250,
            22
          ],
          "text": "prepend crossover 2"
        }
      },
      {
        "box": {
          "id": "edge3",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            335,
            146,
            76,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            335,
            146,
            76,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 4",
              "parameter_shortname": "Split 4",
              "parameter_type": 0,
              "parameter_mmin": 600.0,
              "parameter_mmax": 8000.0,
              "parameter_initial": [
                2500.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            480,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            480,
            250,
            22
          ],
          "text": "line 2500. 10"
        }
      },
      {
        "box": {
          "id": "fmsg3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            480,
            250,
            22
          ],
          "text": "prepend crossover 3"
        }
      },
      {
        "box": {
          "id": "stripe0",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            542,
            7,
            81,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            542,
            7,
            81,
            3
          ],
          "bgcolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label0",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            542,
            16,
            88,
            17
          ],
          "text": "ULTRA LOW",
          "presentation": 1,
          "presentation_rect": [
            542,
            16,
            88,
            17
          ],
          "textcolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "fontsize": 10,
          "varname": "label0",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range0",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            542,
            34,
            88,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            542,
            34,
            88,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range0",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain0",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            554,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            554,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra Low Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "activeneedlecolor": [
            0.69,
            0.53,
            1,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain0msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            480,
            250,
            22
          ],
          "text": "prepend gain 0"
        }
      },
      {
        "box": {
          "id": "solo0",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            542,
            125,
            37,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            542,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra Low Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo0msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            480,
            250,
            22
          ],
          "text": "prepend solo 0"
        }
      },
      {
        "box": {
          "id": "mute0",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            586,
            125,
            37,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            586,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra Low Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute0msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            480,
            250,
            22
          ],
          "text": "prepend mute 0"
        }
      },
      {
        "box": {
          "id": "stripe1",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            633,
            7,
            81,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            633,
            7,
            81,
            3
          ],
          "bgcolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label1",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            633,
            16,
            88,
            17
          ],
          "text": "SUB",
          "presentation": 1,
          "presentation_rect": [
            633,
            16,
            88,
            17
          ],
          "textcolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "fontsize": 10,
          "varname": "label1",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range1",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            633,
            34,
            88,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            633,
            34,
            88,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range1",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain1",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            645,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            645,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Sub Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "activeneedlecolor": [
            0.3,
            0.64,
            1,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain1msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            545,
            250,
            22
          ],
          "text": "prepend gain 1"
        }
      },
      {
        "box": {
          "id": "solo1",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            633,
            125,
            37,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            633,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Sub Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo1msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            545,
            250,
            22
          ],
          "text": "prepend solo 1"
        }
      },
      {
        "box": {
          "id": "mute1",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            677,
            125,
            37,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            677,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Sub Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute1msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            545,
            250,
            22
          ],
          "text": "prepend mute 1"
        }
      },
      {
        "box": {
          "id": "stripe2",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            724,
            7,
            81,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            724,
            7,
            81,
            3
          ],
          "bgcolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label2",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            724,
            16,
            88,
            17
          ],
          "text": "BASS",
          "presentation": 1,
          "presentation_rect": [
            724,
            16,
            88,
            17
          ],
          "textcolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "fontsize": 10,
          "varname": "label2",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range2",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            724,
            34,
            88,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            724,
            34,
            88,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range2",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain2",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            736,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            736,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Bass Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "activeneedlecolor": [
            0.22,
            0.85,
            0.76,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain2msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            545,
            250,
            22
          ],
          "text": "prepend gain 2"
        }
      },
      {
        "box": {
          "id": "solo2",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            724,
            125,
            37,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            724,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Bass Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo2msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            545,
            250,
            22
          ],
          "text": "prepend solo 2"
        }
      },
      {
        "box": {
          "id": "mute2",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            768,
            125,
            37,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            768,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Bass Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute2msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            545,
            250,
            22
          ],
          "text": "prepend mute 2"
        }
      },
      {
        "box": {
          "id": "stripe3",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            815,
            7,
            81,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            815,
            7,
            81,
            3
          ],
          "bgcolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label3",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            815,
            16,
            88,
            17
          ],
          "text": "MIDS",
          "presentation": 1,
          "presentation_rect": [
            815,
            16,
            88,
            17
          ],
          "textcolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "fontsize": 10,
          "varname": "label3",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range3",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            815,
            34,
            88,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            815,
            34,
            88,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range3",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain3",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            827,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            827,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mids Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "activeneedlecolor": [
            0.94,
            0.72,
            0.36,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain3msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            610,
            250,
            22
          ],
          "text": "prepend gain 3"
        }
      },
      {
        "box": {
          "id": "solo3",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            815,
            125,
            37,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            815,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mids Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo3msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            610,
            250,
            22
          ],
          "text": "prepend solo 3"
        }
      },
      {
        "box": {
          "id": "mute3",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            859,
            125,
            37,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            859,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mids Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute3msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            610,
            250,
            22
          ],
          "text": "prepend mute 3"
        }
      },
      {
        "box": {
          "id": "stripe4",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            906,
            7,
            81,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            906,
            7,
            81,
            3
          ],
          "bgcolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label4",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            906,
            16,
            88,
            17
          ],
          "text": "HIGHS",
          "presentation": 1,
          "presentation_rect": [
            906,
            16,
            88,
            17
          ],
          "textcolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "fontsize": 10,
          "varname": "label4",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range4",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            906,
            34,
            88,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            906,
            34,
            88,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range4",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain4",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            918,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            918,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Highs Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "activeneedlecolor": [
            0.95,
            0.43,
            0.49,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain4msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            610,
            250,
            22
          ],
          "text": "prepend gain 4"
        }
      },
      {
        "box": {
          "id": "solo4",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            906,
            125,
            37,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            906,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Highs Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo4msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            610,
            250,
            22
          ],
          "text": "prepend solo 4"
        }
      },
      {
        "box": {
          "id": "mute4",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            950,
            125,
            37,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            950,
            125,
            37,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Highs Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute4msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            610,
            250,
            22
          ],
          "text": "prepend mute 4"
        }
      },
      {
        "box": {
          "id": "trimtitle",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1011,
            15,
            95,
            18
          ],
          "text": "OUTPUT",
          "presentation": 1,
          "presentation_rect": [
            1011,
            15,
            95,
            18
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 10,
          "varname": "trimtitle",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "trim",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1024,
            52,
            60,
            61
          ],
          "presentation": 1,
          "presentation_rect": [
            1024,
            52,
            60,
            61
          ],
          "parameter_enable": 1,
          "varname": "trim",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Output Trim",
              "parameter_shortname": "Trim",
              "parameter_type": 0,
              "parameter_mmin": -24.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0
        }
      },
      {
        "box": {
          "id": "trimmsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            675,
            250,
            22
          ],
          "text": "prepend trim"
        }
      },
      {
        "box": {
          "id": "original",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1008,
            122,
            99,
            21
          ],
          "text": "Original",
          "presentation": 1,
          "presentation_rect": [
            1008,
            122,
            99,
            21
          ],
          "parameter_enable": 1,
          "varname": "original",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Listen to Original",
              "parameter_shortname": "Original",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Bands",
                "Original"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "Original",
          "activebgoncolor": [
            0.45,
            0.62,
            0.64,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textoncolor": [
            0.06,
            0.08,
            0.1,
            1
          ]
        }
      },
      {
        "box": {
          "id": "originalmsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            675,
            250,
            22
          ],
          "text": "prepend original"
        }
      },
      {
        "box": {
          "id": "reset",
          "maxclass": "textbutton",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            1008,
            148,
            99,
            17
          ],
          "text": "Reset mix",
          "presentation": 1,
          "presentation_rect": [
            1008,
            148,
            99,
            17
          ],
          "parameter_enable": 0,
          "fontsize": 9
        }
      },
      {
        "box": {
          "id": "resetmsg",
          "maxclass": "message",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            675,
            250,
            22
          ],
          "text": "command reset"
        }
      },
      {
        "box": {
          "id": "tip",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            547,
            149,
            420,
            16
          ],
          "text": "S = solo  /  M = mute  /  24 dB/oct",
          "presentation": 1,
          "presentation_rect": [
            547,
            149,
            420,
            16
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "tip",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "rlp0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            675,
            250,
            22
          ],
          "text": "r ---bands-lp0"
        }
      },
      {
        "box": {
          "id": "rhp0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            675,
            250,
            22
          ],
          "text": "r ---bands-hp0"
        }
      },
      {
        "box": {
          "id": "rap0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            675,
            250,
            22
          ],
          "text": "r ---bands-ap0"
        }
      },
      {
        "box": {
          "id": "rlp1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            740,
            250,
            22
          ],
          "text": "r ---bands-lp1"
        }
      },
      {
        "box": {
          "id": "rhp1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            740,
            250,
            22
          ],
          "text": "r ---bands-hp1"
        }
      },
      {
        "box": {
          "id": "rap1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            740,
            250,
            22
          ],
          "text": "r ---bands-ap1"
        }
      },
      {
        "box": {
          "id": "rlp2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            740,
            250,
            22
          ],
          "text": "r ---bands-lp2"
        }
      },
      {
        "box": {
          "id": "rhp2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            740,
            250,
            22
          ],
          "text": "r ---bands-hp2"
        }
      },
      {
        "box": {
          "id": "rap2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            740,
            250,
            22
          ],
          "text": "r ---bands-ap2"
        }
      },
      {
        "box": {
          "id": "rlp3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            805,
            250,
            22
          ],
          "text": "r ---bands-lp3"
        }
      },
      {
        "box": {
          "id": "rhp3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            805,
            250,
            22
          ],
          "text": "r ---bands-hp3"
        }
      },
      {
        "box": {
          "id": "rap3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            805,
            250,
            22
          ],
          "text": "r ---bands-ap3"
        }
      },
      {
        "box": {
          "id": "0lp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            805,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0lp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            805,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0hp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            805,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0hp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            870,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0comp0_1",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            870,
            250,
            22
          ],
          "text": "biquad~ 0.98529951312821462 -1.9851906578962613 1 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0comp0_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            870,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0comp0_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            870,
            250,
            22
          ],
          "text": "biquad~ 0.62960400474337408 -1.543121131237386 1 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "0lp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            870,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0lp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            870,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0hp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            935,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0hp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            935,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0comp1_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            935,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0comp1_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            935,
            250,
            22
          ],
          "text": "biquad~ 0.62960400474337408 -1.543121131237386 1 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "0lp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            935,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0lp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            935,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0hp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1000,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0hp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1000,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0comp2_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1000,
            250,
            22
          ],
          "text": "biquad~ 0.62960400474337408 -1.543121131237386 1 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "0lp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1000,
            250,
            22
          ],
          "text": "biquad~ 0.021620718376497008 0.043241436752994016 0.021620718376497008 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "0lp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1000,
            250,
            22
          ],
          "text": "biquad~ 0.021620718376497008 0.043241436752994016 0.021620718376497008 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "0hp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1000,
            250,
            22
          ],
          "text": "biquad~ 0.79318128399519006 -1.5863625679903801 0.79318128399519006 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "0hp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1065,
            250,
            22
          ],
          "text": "biquad~ 0.79318128399519006 -1.5863625679903801 0.79318128399519006 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1lp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1065,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1lp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1065,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1hp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1065,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1hp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1065,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1comp0_1",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1065,
            250,
            22
          ],
          "text": "biquad~ 0.98529951312821462 -1.9851906578962613 1 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1comp0_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1130,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1comp0_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1130,
            250,
            22
          ],
          "text": "biquad~ 0.62960400474337408 -1.543121131237386 1 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1lp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1130,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1lp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1130,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1hp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1130,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1hp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1130,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1comp1_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1195,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1comp1_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1195,
            250,
            22
          ],
          "text": "biquad~ 0.62960400474337408 -1.543121131237386 1 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1lp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1195,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1lp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1195,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1hp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1195,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1hp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1195,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1comp2_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.62960400474337408 -1.543121131237386 1 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1lp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.021620718376497008 0.043241436752994016 0.021620718376497008 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1lp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.021620718376497008 0.043241436752994016 0.021620718376497008 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1hp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.79318128399519006 -1.5863625679903801 0.79318128399519006 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "1hp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.79318128399519006 -1.5863625679903801 0.79318128399519006 -1.543121131237386 0.62960400474337408"
        }
      },
      {
        "box": {
          "id": "gainr0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1260,
            250,
            22
          ],
          "text": "r ---bands-gain0"
        }
      },
      {
        "box": {
          "id": "gainline0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            30,
            1325,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1325,
            250,
            22
          ],
          "text": "r ---bands-gain1"
        }
      },
      {
        "box": {
          "id": "gainline1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            590,
            1325,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1325,
            250,
            22
          ],
          "text": "r ---bands-gain2"
        }
      },
      {
        "box": {
          "id": "gainline2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            1325,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1325,
            250,
            22
          ],
          "text": "r ---bands-gain3"
        }
      },
      {
        "box": {
          "id": "gainline3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            30,
            1390,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1390,
            250,
            22
          ],
          "text": "r ---bands-gain4"
        }
      },
      {
        "box": {
          "id": "gainline4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            590,
            1390,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "trimr",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1390,
            250,
            22
          ],
          "text": "r ---bands-trim"
        }
      },
      {
        "box": {
          "id": "trimline",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            1390,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "dryr",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1390,
            250,
            22
          ],
          "text": "r ---bands-dry"
        }
      },
      {
        "box": {
          "id": "dryline",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            30,
            1455,
            250,
            22
          ],
          "text": "line~ 0."
        }
      },
      {
        "box": {
          "id": "wetline",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1455,
            250,
            22
          ],
          "text": "!-~ 1."
        }
      },
      {
        "box": {
          "id": "sum0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1455,
            250,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "weighted0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1455,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1455,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1455,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1520,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1520,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "wet0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1520,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "dry0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1520,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "output0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1520,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sum1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1520,
            250,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "weighted1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1585,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1585,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1585,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1585,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1585,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "wet1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1585,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "dry1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1650,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "output1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1650,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "buffer0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            590,
            1650,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec0 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            870,
            1650,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec1 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            1650,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec2 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            1650,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec3 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            30,
            1715,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec4 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            310,
            1715,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec5 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            590,
            1715,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec6 @samps 8192"
        }
      },
      {
        "box": {
          "id": "fft",
          "maxclass": "newobj",
          "numinlets": 14,
          "numoutlets": 0,
          "patching_rect": [
            870,
            1715,
            250,
            22
          ],
          "text": "pfft~ bands_fft 16384 4 args ---bands"
        }
      },
      {
        "box": {
          "id": "detail",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1150,
            1715,
            250,
            22
          ],
          "text": "p BANDS \u2014 Spectrum",
          "varname": "detail",
          "patcher": {
            "fileversion": 1,
            "appversion": {
              "major": 8,
              "minor": 6,
              "revision": 5,
              "architecture": "x64",
              "modernui": 1
            },
            "classnamespace": "box",
            "rect": [
              80.0,
              100.0,
              1060.0,
              560.0
            ],
            "openrect": [
              0.0,
              0.0,
              1060.0,
              560.0
            ],
            "openinpresentation": 1,
            "default_fontsize": 11.0,
            "default_fontname": "Arial",
            "bgcolor": [
              0.065,
              0.085,
              0.105,
              1.0
            ],
            "bglocked": 1,
            "boxes": [
              {
                "box": {
                  "id": "scope",
                  "maxclass": "jsui",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    0,
                    0,
                    1060,
                    560
                  ],
                  "presentation": 1,
                  "presentation_rect": [
                    0,
                    0,
                    1060,
                    560
                  ],
                  "filename": "bands_view.js",
                  "jsarguments": [
                    "---bands",
                    1
                  ],
                  "parameter_enable": 0,
                  "border": 0
                }
              },
              {
                "box": {
                  "id": "recv",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    276.0,
                    170.0,
                    22.0
                  ],
                  "text": "r ---bands-view"
                }
              },
              {
                "box": {
                  "id": "clk",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    304.0,
                    170.0,
                    22.0
                  ],
                  "text": "qmetro 33"
                }
              },
              {
                "box": {
                  "id": "on",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    332.0,
                    170.0,
                    22.0
                  ],
                  "text": "loadmess 1"
                }
              },
              {
                "box": {
                  "id": "cmd",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 0,
                  "patching_rect": [
                    30.0,
                    360.0,
                    170.0,
                    22.0
                  ],
                  "text": "s ---bands-command"
                }
              },
              {
                "box": {
                  "id": "window",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 2,
                  "patching_rect": [
                    30.0,
                    388.0,
                    170.0,
                    22.0
                  ],
                  "text": "thispatcher"
                }
              },
              {
                "box": {
                  "id": "front",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    416.0,
                    170.0,
                    22.0
                  ],
                  "text": "r ---bands-open"
                }
              },
              {
                "box": {
                  "id": "show",
                  "maxclass": "message",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    444.0,
                    170.0,
                    22.0
                  ],
                  "text": "window flags float, window exec, front, topmost 1"
                }
              },
              {
                "box": {
                  "id": "windowload",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    472.0,
                    170.0,
                    22.0
                  ],
                  "text": "loadbang"
                }
              },
              {
                "box": {
                  "id": "windowinit",
                  "maxclass": "message",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    500.0,
                    170.0,
                    22.0
                  ],
                  "text": "window flags float, window exec"
                }
              }
            ],
            "lines": [
              {
                "patchline": {
                  "source": [
                    "recv",
                    0
                  ],
                  "destination": [
                    "scope",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "on",
                    0
                  ],
                  "destination": [
                    "clk",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "clk",
                    0
                  ],
                  "destination": [
                    "scope",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "scope",
                    0
                  ],
                  "destination": [
                    "cmd",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "front",
                    0
                  ],
                  "destination": [
                    "show",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "show",
                    0
                  ],
                  "destination": [
                    "window",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "windowload",
                    0
                  ],
                  "destination": [
                    "windowinit",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "windowinit",
                    0
                  ],
                  "destination": [
                    "window",
                    0
                  ]
                }
              }
            ],
            "autosave": 0
          }
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "cmd",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "viewbus",
            0
          ],
          "destination": [
            "view",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "view",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clockon",
            0
          ],
          "destination": [
            "clock",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clock",
            0
          ],
          "destination": [
            "view",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dev",
            0
          ],
          "destination": [
            "defer",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "defer",
            0
          ],
          "destination": [
            "init",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "init",
            0
          ],
          "destination": [
            "initmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "initmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "load",
            0
          ],
          "destination": [
            "loaddefer",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "loaddefer",
            0
          ],
          "destination": [
            "init",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dsp",
            1
          ],
          "destination": [
            "sr",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sr",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "init",
            1
          ],
          "destination": [
            "dsp",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge0",
            0
          ],
          "destination": [
            "fpack0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack0",
            0
          ],
          "destination": [
            "fline0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline0",
            0
          ],
          "destination": [
            "fmsg0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg0",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge1",
            0
          ],
          "destination": [
            "fpack1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack1",
            0
          ],
          "destination": [
            "fline1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline1",
            0
          ],
          "destination": [
            "fmsg1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg1",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge2",
            0
          ],
          "destination": [
            "fpack2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack2",
            0
          ],
          "destination": [
            "fline2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline2",
            0
          ],
          "destination": [
            "fmsg2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg2",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge3",
            0
          ],
          "destination": [
            "fpack3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack3",
            0
          ],
          "destination": [
            "fline3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline3",
            0
          ],
          "destination": [
            "fmsg3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg3",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain0",
            0
          ],
          "destination": [
            "gain0msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain0msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo0",
            0
          ],
          "destination": [
            "solo0msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo0msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute0",
            0
          ],
          "destination": [
            "mute0msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute0msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain1",
            0
          ],
          "destination": [
            "gain1msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain1msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo1",
            0
          ],
          "destination": [
            "solo1msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo1msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute1",
            0
          ],
          "destination": [
            "mute1msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute1msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain2",
            0
          ],
          "destination": [
            "gain2msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain2msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo2",
            0
          ],
          "destination": [
            "solo2msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo2msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute2",
            0
          ],
          "destination": [
            "mute2msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute2msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain3",
            0
          ],
          "destination": [
            "gain3msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain3msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo3",
            0
          ],
          "destination": [
            "solo3msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo3msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute3",
            0
          ],
          "destination": [
            "mute3msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute3msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain4",
            0
          ],
          "destination": [
            "gain4msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain4msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo4",
            0
          ],
          "destination": [
            "solo4msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo4msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute4",
            0
          ],
          "destination": [
            "mute4msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute4msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trim",
            0
          ],
          "destination": [
            "trimmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "original",
            0
          ],
          "destination": [
            "originalmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "originalmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "reset",
            0
          ],
          "destination": [
            "resetmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "resetmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "0lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "0lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp0a",
            0
          ],
          "destination": [
            "0lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "0lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "0hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "0hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp0a",
            0
          ],
          "destination": [
            "0hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "0hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp0b",
            0
          ],
          "destination": [
            "0comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap1",
            0
          ],
          "destination": [
            "0comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_1",
            0
          ],
          "destination": [
            "0comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "0comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_2",
            0
          ],
          "destination": [
            "0comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "0comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp0b",
            0
          ],
          "destination": [
            "0lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "0lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp1a",
            0
          ],
          "destination": [
            "0lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "0lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp0b",
            0
          ],
          "destination": [
            "0hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "0hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp1a",
            0
          ],
          "destination": [
            "0hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "0hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp1b",
            0
          ],
          "destination": [
            "0comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "0comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_2",
            0
          ],
          "destination": [
            "0comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "0comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp1b",
            0
          ],
          "destination": [
            "0lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "0lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp2a",
            0
          ],
          "destination": [
            "0lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "0lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp1b",
            0
          ],
          "destination": [
            "0hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "0hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp2a",
            0
          ],
          "destination": [
            "0hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "0hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp2b",
            0
          ],
          "destination": [
            "0comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "0comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp2b",
            0
          ],
          "destination": [
            "0lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "0lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp3a",
            0
          ],
          "destination": [
            "0lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "0lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp2b",
            0
          ],
          "destination": [
            "0hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "0hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp3a",
            0
          ],
          "destination": [
            "0hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "0hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "1lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "1lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp0a",
            0
          ],
          "destination": [
            "1lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "1lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "1hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "1hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp0a",
            0
          ],
          "destination": [
            "1hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "1hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp0b",
            0
          ],
          "destination": [
            "1comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap1",
            0
          ],
          "destination": [
            "1comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_1",
            0
          ],
          "destination": [
            "1comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "1comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_2",
            0
          ],
          "destination": [
            "1comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "1comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp0b",
            0
          ],
          "destination": [
            "1lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "1lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp1a",
            0
          ],
          "destination": [
            "1lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "1lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp0b",
            0
          ],
          "destination": [
            "1hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "1hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp1a",
            0
          ],
          "destination": [
            "1hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "1hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp1b",
            0
          ],
          "destination": [
            "1comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "1comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_2",
            0
          ],
          "destination": [
            "1comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "1comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp1b",
            0
          ],
          "destination": [
            "1lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "1lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp2a",
            0
          ],
          "destination": [
            "1lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "1lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp1b",
            0
          ],
          "destination": [
            "1hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "1hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp2a",
            0
          ],
          "destination": [
            "1hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "1hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp2b",
            0
          ],
          "destination": [
            "1comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "1comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp2b",
            0
          ],
          "destination": [
            "1lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "1lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp3a",
            0
          ],
          "destination": [
            "1lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "1lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp2b",
            0
          ],
          "destination": [
            "1hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "1hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp3a",
            0
          ],
          "destination": [
            "1hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "1hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr0",
            0
          ],
          "destination": [
            "gainline0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr1",
            0
          ],
          "destination": [
            "gainline1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr2",
            0
          ],
          "destination": [
            "gainline2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr3",
            0
          ],
          "destination": [
            "gainline3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr4",
            0
          ],
          "destination": [
            "gainline4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimr",
            0
          ],
          "destination": [
            "trimline",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryr",
            0
          ],
          "destination": [
            "dryline",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryline",
            0
          ],
          "destination": [
            "wetline",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_3",
            0
          ],
          "destination": [
            "weighted0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline0",
            0
          ],
          "destination": [
            "weighted0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_0",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_3",
            0
          ],
          "destination": [
            "weighted0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline1",
            0
          ],
          "destination": [
            "weighted0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_1",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp2_3",
            0
          ],
          "destination": [
            "weighted0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline2",
            0
          ],
          "destination": [
            "weighted0_2",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_2",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp3b",
            0
          ],
          "destination": [
            "weighted0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline3",
            0
          ],
          "destination": [
            "weighted0_3",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_3",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp3b",
            0
          ],
          "destination": [
            "weighted0_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline4",
            0
          ],
          "destination": [
            "weighted0_4",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_4",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum0",
            0
          ],
          "destination": [
            "wet0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wetline",
            0
          ],
          "destination": [
            "wet0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "dry0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryline",
            0
          ],
          "destination": [
            "dry0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wet0",
            0
          ],
          "destination": [
            "output0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dry0",
            0
          ],
          "destination": [
            "output0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimline",
            0
          ],
          "destination": [
            "output0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output0",
            0
          ],
          "destination": [
            "out",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_3",
            0
          ],
          "destination": [
            "weighted1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline0",
            0
          ],
          "destination": [
            "weighted1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_0",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_3",
            0
          ],
          "destination": [
            "weighted1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline1",
            0
          ],
          "destination": [
            "weighted1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_1",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp2_3",
            0
          ],
          "destination": [
            "weighted1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline2",
            0
          ],
          "destination": [
            "weighted1_2",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_2",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp3b",
            0
          ],
          "destination": [
            "weighted1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline3",
            0
          ],
          "destination": [
            "weighted1_3",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_3",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp3b",
            0
          ],
          "destination": [
            "weighted1_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline4",
            0
          ],
          "destination": [
            "weighted1_4",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_4",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum1",
            0
          ],
          "destination": [
            "wet1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wetline",
            0
          ],
          "destination": [
            "wet1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "dry1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryline",
            0
          ],
          "destination": [
            "dry1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wet1",
            0
          ],
          "destination": [
            "output1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dry1",
            0
          ],
          "destination": [
            "output1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimline",
            0
          ],
          "destination": [
            "output1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output1",
            0
          ],
          "destination": [
            "out",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "fft",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "fft",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output0",
            0
          ],
          "destination": [
            "fft",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output1",
            0
          ],
          "destination": [
            "fft",
            3
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_0",
            0
          ],
          "destination": [
            "fft",
            4
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_0",
            0
          ],
          "destination": [
            "fft",
            5
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_1",
            0
          ],
          "destination": [
            "fft",
            6
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_1",
            0
          ],
          "destination": [
            "fft",
            7
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_2",
            0
          ],
          "destination": [
            "fft",
            8
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_2",
            0
          ],
          "destination": [
            "fft",
            9
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_3",
            0
          ],
          "destination": [
            "fft",
            10
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_3",
            0
          ],
          "destination": [
            "fft",
            11
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_4",
            0
          ],
          "destination": [
            "fft",
            12
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_4",
            0
          ],
          "destination": [
            "fft",
            13
          ]
        }
      }
    ],
    "autosave": 0,
    "devicewidth": 1120,
    "latency": 0,
    "enablehscroll": 0,
    "enablevscroll": 0,
    "description": "Five-band stereo listening and low-end spectrum workbench.",
    "digest": "BANDS \u2014 five-band spectrum and listening",
    "tags": "audio analysis spectrum crossover bass",
    "parameters": {
      "edge0": [
        "Crossover 1",
        "Split 1",
        0
      ],
      "edge1": [
        "Crossover 2",
        "Split 2",
        0
      ],
      "edge2": [
        "Crossover 3",
        "Split 3",
        0
      ],
      "edge3": [
        "Crossover 4",
        "Split 4",
        0
      ],
      "gain0": [
        "Ultra Low Gain",
        "Gain",
        0
      ],
      "solo0": [
        "Ultra Low Solo",
        "S",
        0
      ],
      "mute0": [
        "Ultra Low Mute",
        "M",
        0
      ],
      "gain1": [
        "Sub Gain",
        "Gain",
        0
      ],
      "solo1": [
        "Sub Solo",
        "S",
        0
      ],
      "mute1": [
        "Sub Mute",
        "M",
        0
      ],
      "gain2": [
        "Bass Gain",
        "Gain",
        0
      ],
      "solo2": [
        "Bass Solo",
        "S",
        0
      ],
      "mute2": [
        "Bass Mute",
        "M",
        0
      ],
      "gain3": [
        "Mids Gain",
        "Gain",
        0
      ],
      "solo3": [
        "Mids Solo",
        "S",
        0
      ],
      "mute3": [
        "Mids Mute",
        "M",
        0
      ],
      "gain4": [
        "Highs Gain",
        "Gain",
        0
      ],
      "solo4": [
        "Highs Solo",
        "S",
        0
      ],
      "mute4": [
        "Highs Mute",
        "M",
        0
      ],
      "trim": [
        "Output Trim",
        "Trim",
        0
      ],
      "original": [
        "Listen to Original",
        "Original",
        0
      ],
      "parameterbanks": {
        "0": {
          "index": 0,
          "name": "Mix",
          "parameters": [
            "Ultra Low Gain",
            "Sub Gain",
            "Bass Gain",
            "Mids Gain",
            "Highs Gain",
            "Output Trim",
            "Listen to Original",
            "-"
          ]
        },
        "1": {
          "index": 1,
          "name": "Crossovers",
          "parameters": [
            "Crossover 1",
            "Crossover 2",
            "Crossover 3",
            "Crossover 4",
            "-",
            "-",
            "-",
            "-"
          ]
        },
        "2": {
          "index": 2,
          "name": "Solo",
          "parameters": [
            "Ultra Low Solo",
            "Sub Solo",
            "Bass Solo",
            "Mids Solo",
            "Highs Solo",
            "-",
            "-",
            "-"
          ]
        },
        "3": {
          "index": 3,
          "name": "Mute",
          "parameters": [
            "Ultra Low Mute",
            "Sub Mute",
            "Bass Mute",
            "Mids Mute",
            "Highs Mute",
            "-",
            "-",
            "-"
          ]
        }
      },
      "inherited_shortname": 1
    },
    "dependency_cache": [
      {
        "name": "bands_control.js",
        "type": "TEXT",
        "implicit": 1
      },
      {
        "name": "bands_view.js",
        "type": "TEXT",
        "implicit": 1
      },
      {
        "name": "bands_fft.maxpat",
        "type": "JSON",
        "implicit": 1
      }
    ],
    "project": {
      "version": 1,
      "amxdtype": 1633771873,
      "autoorganize": 0,
      "hideprojectwindow": 1,
      "showdependencies": 1,
      "autolocalize": 0,
      "contents": {
        "patchers": {},
        "code": {}
      },
      "layout": {},
      "searchpath": {},
      "readonly": 0,
      "devpathtype": 0,
      "devpath": "."
    }
  }
}
