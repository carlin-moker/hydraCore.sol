// Script de Despliegue para Red 62 - CosmicGemLogistic
const { ethers } = require("hardhat");

async function main() {
    console.log("Iniciando despliegue de infraestructura soberana...");

    // 1. Desplegar CosmicRoute (Intercambio sin gas)
    const CosmicRoute = await ethers.getContractFactory("CosmicRoute");
    const cosmicRoute = await CosmicRoute.deploy();
    await cosmicRoute.deployed();

    console.log("CosmicRoute desplegado en:", cosmicRoute.address);
    console.log("Estado: OPERATIVO - Operador: carlin-moker");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
