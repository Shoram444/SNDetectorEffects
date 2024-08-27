using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase

const CAT_FILE = joinpath("data/sims/Boff/CAT.root")
const TIT_FILE = joinpath("data/sims/Boff/TIT.root")

const ALL_VARS = [
    "x1SD",
    "y1SD",
    "z1SD",
    "x2SD",
    "y2SD",
    "z2SD",
    "px1SD",
    "py1SD",
    "pz1SD",
    "px2SD",
    "py2SD",
    "pz2SD",
    "theta",
    "x1SE",
    "y1SE",
    "z1SE",
    "x2SE",
    "y2SE",
    "z2SE",
    "px1SE",
    "py1SE",
    "pz1SE",
    "px2SE",
    "py2SE",
    "pz2SE",
    "phiSE",
    "x1RE",
    "y1RE",
    "z1RE",
    "x2RE",
    "y2RE",
    "z2RE",
    "phiRE",
    "recoEnergy1",
    "recoEnergy2",
    "simuEnergy1",
    "simuEnergy2"
]

const VERTEX_POS_VARS = [
    "x1SD",
    "y1SD",
    "z1SD",
    "x2SD",
    "y2SD",
    "z2SD",
    "x1SE",
    "y1SE",
    "z1SE",
    "x2SE",
    "y2SE",
    "z2SE",
    "recoEnergy1",
    "recoEnergy2",
    "simuEnergy1",
    "simuEnergy2"
]

const ANGLES_VARS = [
    "theta",
    "px1SE",
    "py1SE",
    "pz1SE",
    "px2SE",
    "py2SE",
    "pz2SE",
    "phiSE",
    "phiRE",
    "recoEnergy1",
    "recoEnergy2",
    "simuEnergy1",
    "simuEnergy2",
    "z1RE",
    "z2RE",
]