import { useState, useEffect } from "react";
import { BigNumber, ethers } from "ethers";
import abi from "./abi";
import address from "./address";

export default function index() {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [daoContract, setDAOContract] = useState(null);
  const [numProposals, setNumProposals] = useState(0);
  const [proposals, setProposals] = useState([]);
  const [votingPower, setVotingPower] = useState(0);

  useEffect(() => {
    async function loadWeb3() {
      const { ethereum } = window;
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        setProvider(provider);
        setSigner(signer);
        try {
          await window.ethereum.enable();
          const accounts = await provider.listAccounts();
          setAccounts(accounts);
        } catch (error) {
          console.error(error);
        }
      } else {
        console.error("No Web3 provider detected");
      }
    }
    loadWeb3();
  }, []);

  useEffect(() => {
    async function loadBlockchainData() {
      if (signer) {
        const dao = new ethers.Contract(address, abi, signer);
        setDAOContract(dao);
        const proposals = await dao.fetchProposals();
        setProposals(proposals);

        const votingPower = await dao.rights();
        setVotingPower(parseInt(votingPower));
      }
    }
    loadBlockchainData();
  }, [signer]);

  async function createProposal(title, description) {
    await daoContract.createProposal(title, description);
  }

  async function vote(proposalId, vote) {
    const id = parseInt(proposalId);
    console.log(id, vote);
    // await daoContract.vote(new BigNumber(proposalId), vote);
    await daoContract.vote(id, vote);
  }

  async function executeProposal(proposalId) {
    await daoContract.executeProposal(proposalId);
  }

  async function buy_token(amount) {
    await daoContract.mint(amount);
  }

  return (
    <div>
      <div>
        <h1>DAO App</h1>
        {accounts.length > 0 ? (
          <div>
            <p>Your account: {accounts[0]}</p>
            <p>Your voting power: {votingPower}</p>
            <h2>Buy Voting Tokens</h2>
            <input type="number" placeholder="amount" id="amount" />
            <button
              onClick={() => buy_token(document.getElementById("amount").value)}
            >
              Buy
            </button>
            <h2>Proposals</h2>
            <label>
              Title:
              <input type="text" id="title" />
            </label>
            <br />
            <label>
              Description:
              <input type="text" id="description" />
            </label>
            <br />
            <button
              onClick={() =>
                createProposal(
                  document.getElementById("title").value,
                  document.getElementById("description").value
                )
              }
            >
              Create Proposal
            </button>
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Title</th>
                  <th>Description</th>
                  <th>Yes Votes</th>
                  <th>No Votes</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {proposals.map((proposal) => (
                  <tr key={proposal.id}>
                    <td>{parseInt(proposal.id)}</td>
                    <td>{proposal.title}</td>
                    <td>{proposal.description}</td>
                    <td>{parseInt(proposal.forVotes)}</td>
                    <td>{parseInt(proposal.againstVotes)}</td>
                    <td>
                      {proposal.executed ? (
                        "Executed"
                      ) : (
                        <div>
                          <button onClick={() => vote(proposal.id, true)}>
                            Yes
                          </button>
                          <button onClick={() => vote(proposal.id, false)}>
                            No
                          </button>
                          <button onClick={() => executeProposal(proposal.id)}>
                            Execute
                          </button>
                        </div>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <p>Connect your wallet to view and create proposals.</p>
        )}
      </div>
    </div>
  );
}
