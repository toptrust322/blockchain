pragma solidity ^0.4.25;

contract DigitalLocker
{
    enum StateType { Requested, DocumentReview, AvailableToShare, SharingRequestPending, SharingWithThirdParty, Terminated }
    address public Owner;
    address public BankAgent;
    string public LockerFriendlyName;
    string public LockerIdentifier;
    address public CurrentAuthorizedUser;
    string public ExpirationDate;
    string public Image;
    address public ThirdPartyRequestor;
    string public IntendedPurpose;
    string public LockerStatus;
    string public RejectionReason;
    StateType public State;

    constructor(string lockerFriendlyName, address bankAgent)
    {
        Owner = msg.sender;
        LockerFriendlyName = lockerFriendlyName;

        State = StateType.DocumentReview; //////////////// should be StateType.Requested?

        BankAgent = bankAgent;
    }

    function BeginReviewProcess()
    {
        /* Need to update, likely with registry to confirm sender is agent
        Also need to add a function to re-assign the agent.
        */
     if (Owner == msg.sender)
        {
            revert();
        }
        BankAgent = msg.sender;

        LockerStatus = "Pending";
        State = StateType.DocumentReview;
    }

    function RejectApplication(string rejectionReason)
    {
     if (BankAgent != msg.sender)
        {
            revert();
        }

        RejectionReason = rejectionReason;
        LockerStatus = "Rejected";
        State = StateType.DocumentReview;
    }

    function UploadDocuments(string lockerIdentifier, string image)
    {
        if (BankAgent != msg.sender)
        {
            revert();
        }
        LockerStatus = "Approved";
        Image = image;
        LockerIdentifier = lockerIdentifier;
        State = StateType.AvailableToShare;
    }

    function ShareWithThirdParty(address thirdPartyRequestor, string expirationDate, string intendedPurpose)
    {
        if (Owner != msg.sender)
        {
            revert();
        }

        ThirdPartyRequestor = thirdPartyRequestor;
        CurrentAuthorizedUser = ThirdPartyRequestor;

        LockerStatus ="Shared" ;
        IntendedPurpose = intendedPurpose;
        ExpirationDate = expirationDate;
        State = StateType.SharingWithThirdParty;
    }

    function AcceptSharingRequest()
    {
        if (Owner != msg.sender)
        {
            revert();
        }

        CurrentAuthorizedUser = ThirdPartyRequestor;
        State = StateType.SharingWithThirdParty;
    }

    function RejectSharingRequest()
    {
        if (Owner != msg.sender)
        {
            revert();
        }
        LockerStatus ="Available";
        CurrentAuthorizedUser=0x0;
        State = StateType.AvailableToShare;
    }

    function RequestLockerAccess(string intendedPurpose)
    {
        if (Owner == msg.sender)
        {
            revert();
        }

        ThirdPartyRequestor = msg.sender;
        IntendedPurpose=intendedPurpose;
        State = StateType.SharingRequestPending;
    }

    function ReleaseLockerAccess()
    {

        if (CurrentAuthorizedUser != msg.sender)
        {
            revert();
        }
        LockerStatus ="Available";
        ThirdPartyRequestor = 0x0;
        CurrentAuthorizedUser = 0x0;
        IntendedPurpose="";
        State = StateType.AvailableToShare;
    }

    function RevokeAccessFromThirdParty()
    {
        if (Owner != msg.sender)
        {
            revert();
        }
        LockerStatus ="Available";
        CurrentAuthorizedUser=0x0;
        State = StateType.AvailableToShare;
    }

    function Terminate()
    {
        if (Owner != msg.sender)
        {
            revert();
        }
        CurrentAuthorizedUser=0x0;
        State = StateType.Terminated;
    }
}
