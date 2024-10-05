const {expect} = require('chai');
const {ethers} = require('hardhat');

describe('Counter', function() {
    let counter;

    before(async function(){
        const Counter = await ethers.getContractFactory('Counter');
        counter = await Counter.deploy();
        await counter.waitForDeployment();    
    });

    it('Initial count should be 0', async function(){
        expect(await counter.get()).to.equal(0);
    });

    it('Increment should increase the count', async function(){
        await counter.inc();
        expect(await counter.get()).to.equal(1);
    });

    it('Decrement should increase the count', async function(){
        await counter.dec();
        expect(await counter.get()).to.equal(0);
    });
});