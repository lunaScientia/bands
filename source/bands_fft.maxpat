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
      1200.0,
      700.0
    ],
    "openrect": [
      0.0,
      0.0,
      1200.0,
      700.0
    ],
    "openinpresentation": 0,
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
          "id": "fft0_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            248.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 1 hanning"
        }
      },
      {
        "box": {
          "id": "sq0_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            276.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq0_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            304.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft0_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            332.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 2 hanning"
        }
      },
      {
        "box": {
          "id": "sq0_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            360.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq0_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            388.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            416.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke0",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            444.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec0"
        }
      },
      {
        "box": {
          "id": "fft1_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            472.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 3 hanning"
        }
      },
      {
        "box": {
          "id": "sq1_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            500.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq1_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            528.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft1_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            556.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 4 hanning"
        }
      },
      {
        "box": {
          "id": "sq1_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            584.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq1_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            612.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            640.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke1",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            668.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec1"
        }
      },
      {
        "box": {
          "id": "fft2_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            696.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 5 hanning"
        }
      },
      {
        "box": {
          "id": "sq2_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            724.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq2_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            752.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft2_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            780.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 6 hanning"
        }
      },
      {
        "box": {
          "id": "sq2_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            808.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq2_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            836.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            864.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke2",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            892.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec2"
        }
      },
      {
        "box": {
          "id": "fft3_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            920.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 7 hanning"
        }
      },
      {
        "box": {
          "id": "sq3_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            948.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq3_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            976.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft3_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1004.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 8 hanning"
        }
      },
      {
        "box": {
          "id": "sq3_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1032.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq3_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1060.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1088.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke3",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            1116.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec3"
        }
      },
      {
        "box": {
          "id": "fft4_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1144.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 9 hanning"
        }
      },
      {
        "box": {
          "id": "sq4_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1172.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq4_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1200.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft4_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1228.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 10 hanning"
        }
      },
      {
        "box": {
          "id": "sq4_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1256.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq4_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1284.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1312.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke4",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            1340.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec4"
        }
      },
      {
        "box": {
          "id": "fft5_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1368.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 11 hanning"
        }
      },
      {
        "box": {
          "id": "sq5_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1396.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq5_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1424.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft5_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1452.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 12 hanning"
        }
      },
      {
        "box": {
          "id": "sq5_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1480.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq5_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1508.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power5",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1536.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke5",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            1564.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec5"
        }
      },
      {
        "box": {
          "id": "fft6_0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1592.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 13 hanning"
        }
      },
      {
        "box": {
          "id": "sq6_0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1620.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq6_0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1648.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "fft6_1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            30.0,
            1676.0,
            170.0,
            22.0
          ],
          "text": "fftin~ 14 hanning"
        }
      },
      {
        "box": {
          "id": "sq6_1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1704.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sq6_1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1732.0,
            170.0,
            22.0
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "power6",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30.0,
            1760.0,
            170.0,
            22.0
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "poke6",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 0,
          "patching_rect": [
            30.0,
            1788.0,
            170.0,
            22.0
          ],
          "text": "poke~ #1-spec6"
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "fft0_0",
            0
          ],
          "destination": [
            "sq0_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_0",
            0
          ],
          "destination": [
            "sq0_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_0",
            1
          ],
          "destination": [
            "sq0_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_0",
            1
          ],
          "destination": [
            "sq0_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_1",
            0
          ],
          "destination": [
            "sq0_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_1",
            0
          ],
          "destination": [
            "sq0_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_1",
            1
          ],
          "destination": [
            "sq0_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_1",
            1
          ],
          "destination": [
            "sq0_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq0_0_0",
            0
          ],
          "destination": [
            "power0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq0_0_1",
            0
          ],
          "destination": [
            "power0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq0_1_0",
            0
          ],
          "destination": [
            "power0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq0_1_1",
            0
          ],
          "destination": [
            "power0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power0",
            0
          ],
          "destination": [
            "poke0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft0_0",
            2
          ],
          "destination": [
            "poke0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_0",
            0
          ],
          "destination": [
            "sq1_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_0",
            0
          ],
          "destination": [
            "sq1_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_0",
            1
          ],
          "destination": [
            "sq1_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_0",
            1
          ],
          "destination": [
            "sq1_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_1",
            0
          ],
          "destination": [
            "sq1_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_1",
            0
          ],
          "destination": [
            "sq1_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_1",
            1
          ],
          "destination": [
            "sq1_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_1",
            1
          ],
          "destination": [
            "sq1_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq1_0_0",
            0
          ],
          "destination": [
            "power1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq1_0_1",
            0
          ],
          "destination": [
            "power1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq1_1_0",
            0
          ],
          "destination": [
            "power1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq1_1_1",
            0
          ],
          "destination": [
            "power1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power1",
            0
          ],
          "destination": [
            "poke1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft1_0",
            2
          ],
          "destination": [
            "poke1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_0",
            0
          ],
          "destination": [
            "sq2_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_0",
            0
          ],
          "destination": [
            "sq2_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_0",
            1
          ],
          "destination": [
            "sq2_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_0",
            1
          ],
          "destination": [
            "sq2_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_1",
            0
          ],
          "destination": [
            "sq2_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_1",
            0
          ],
          "destination": [
            "sq2_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_1",
            1
          ],
          "destination": [
            "sq2_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_1",
            1
          ],
          "destination": [
            "sq2_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq2_0_0",
            0
          ],
          "destination": [
            "power2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq2_0_1",
            0
          ],
          "destination": [
            "power2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq2_1_0",
            0
          ],
          "destination": [
            "power2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq2_1_1",
            0
          ],
          "destination": [
            "power2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power2",
            0
          ],
          "destination": [
            "poke2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft2_0",
            2
          ],
          "destination": [
            "poke2",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_0",
            0
          ],
          "destination": [
            "sq3_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_0",
            0
          ],
          "destination": [
            "sq3_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_0",
            1
          ],
          "destination": [
            "sq3_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_0",
            1
          ],
          "destination": [
            "sq3_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_1",
            0
          ],
          "destination": [
            "sq3_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_1",
            0
          ],
          "destination": [
            "sq3_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_1",
            1
          ],
          "destination": [
            "sq3_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_1",
            1
          ],
          "destination": [
            "sq3_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq3_0_0",
            0
          ],
          "destination": [
            "power3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq3_0_1",
            0
          ],
          "destination": [
            "power3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq3_1_0",
            0
          ],
          "destination": [
            "power3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq3_1_1",
            0
          ],
          "destination": [
            "power3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power3",
            0
          ],
          "destination": [
            "poke3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft3_0",
            2
          ],
          "destination": [
            "poke3",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_0",
            0
          ],
          "destination": [
            "sq4_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_0",
            0
          ],
          "destination": [
            "sq4_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_0",
            1
          ],
          "destination": [
            "sq4_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_0",
            1
          ],
          "destination": [
            "sq4_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_1",
            0
          ],
          "destination": [
            "sq4_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_1",
            0
          ],
          "destination": [
            "sq4_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_1",
            1
          ],
          "destination": [
            "sq4_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_1",
            1
          ],
          "destination": [
            "sq4_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq4_0_0",
            0
          ],
          "destination": [
            "power4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq4_0_1",
            0
          ],
          "destination": [
            "power4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq4_1_0",
            0
          ],
          "destination": [
            "power4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq4_1_1",
            0
          ],
          "destination": [
            "power4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power4",
            0
          ],
          "destination": [
            "poke4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft4_0",
            2
          ],
          "destination": [
            "poke4",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_0",
            0
          ],
          "destination": [
            "sq5_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_0",
            0
          ],
          "destination": [
            "sq5_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_0",
            1
          ],
          "destination": [
            "sq5_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_0",
            1
          ],
          "destination": [
            "sq5_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_1",
            0
          ],
          "destination": [
            "sq5_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_1",
            0
          ],
          "destination": [
            "sq5_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_1",
            1
          ],
          "destination": [
            "sq5_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_1",
            1
          ],
          "destination": [
            "sq5_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq5_0_0",
            0
          ],
          "destination": [
            "power5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq5_0_1",
            0
          ],
          "destination": [
            "power5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq5_1_0",
            0
          ],
          "destination": [
            "power5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq5_1_1",
            0
          ],
          "destination": [
            "power5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power5",
            0
          ],
          "destination": [
            "poke5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft5_0",
            2
          ],
          "destination": [
            "poke5",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_0",
            0
          ],
          "destination": [
            "sq6_0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_0",
            0
          ],
          "destination": [
            "sq6_0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_0",
            1
          ],
          "destination": [
            "sq6_0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_0",
            1
          ],
          "destination": [
            "sq6_0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_1",
            0
          ],
          "destination": [
            "sq6_1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_1",
            0
          ],
          "destination": [
            "sq6_1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_1",
            1
          ],
          "destination": [
            "sq6_1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_1",
            1
          ],
          "destination": [
            "sq6_1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq6_0_0",
            0
          ],
          "destination": [
            "power6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq6_0_1",
            0
          ],
          "destination": [
            "power6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq6_1_0",
            0
          ],
          "destination": [
            "power6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sq6_1_1",
            0
          ],
          "destination": [
            "power6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "power6",
            0
          ],
          "destination": [
            "poke6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fft6_0",
            2
          ],
          "destination": [
            "poke6",
            1
          ]
        }
      }
    ],
    "autosave": 0
  }
}
