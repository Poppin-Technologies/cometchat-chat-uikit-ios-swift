//  CometChatBannedMembers.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

public class CometChatBannedMembers: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var bannedMembers:[CometChatPro.GroupMember] = [CometChatPro.GroupMember]()
    var bannedMemberRequest: BannedGroupMembersRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sectionsArray = [String]()
    var currentGroup: CometChatPro.Group?
    var mode: ModeratorMode?
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
       
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.addObservers()
        self.setupNavigationBar()
        self.set(title: "Banned Members", mode: .always)
        if let group = currentGroup {
            fetchBannedMembers(for: group)
        }
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.addObservers()
    }
    
    // MARK: - Public instance methods
    
    
    /**
     This method specifies the `group` Objects to add or remove admin it it..
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func set(group: CometChatPro.Group){
        self.currentGroup = group
    }
    
    /**
     This method specifies the navigation bar title for CometChatAddModerators.
     - Parameters:
     - title: This takes the String to set title for CometChatAddModerators.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = title.localized()
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }}
    
    /**
     This method specifies the navigation bar color for CometChatAddModerators.
     - Parameters:
     - barColor: This specifes navigation bar color.
     - color:  This specifes navigation bar title color.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc public func set(barColor :UIColor, titleColor color: UIColor){
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navBarAppearance.backgroundColor = barColor
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
        }
    }
    
    
    // MARK: - Private instance methods
    
    /**
     This method observes for perticular events such as `didRefreshMembers` in CometChatAddModerators.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    fileprivate func addObservers(){
        CometChat.groupdelegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshMembers(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
    }
    
    /**
     This method refreshes the group member list.
     - Parameter notification: Specifies the `NSNotification` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func didRefreshMembers(_ notification: NSNotification) {
        if let group = currentGroup {
            self.fetchBannedMembers(for: group)
        }
    }
    
    /**
     This method setup the tableview to load CometChatAddModerators.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     
     */
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
    }
    
    /**
     This method register the cells for CometChatAddModerators.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func registerCells(){
        let CometChatAddMemberItem  = UINib.init(nibName: "CometChatAddMemberItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatAddMemberItem, forCellReuseIdentifier: "CometChatAddMemberItem")
        
        let CometChatMembersItem  = UINib.init(nibName: "CometChatMembersItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatMembersItem, forCellReuseIdentifier: "CometChatMembersItem")
    }
    
    
    /**
     This method setup navigationBar for addAdmins viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
            
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            let closeButton = UIBarButtonItem(title: "CLOSE".localized(), style: .plain, target: self, action: #selector(closeButtonPressed))
            closeButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = closeButton
            
            switch mode {
            case .fetchGroupMembers: self.set(title: "MAKE_GROUP_MODERATOR".localized(), mode: .automatic)
            case .fetchModerators: self.set(title: "Moderators".localized(), mode: .automatic)
            case .none: break
            }
            self.setLargeTitleDisplayMode(.always)
        }
    }
    
    /**
     This method triggers when user clicks on close button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     This method fetches the list of Admins for particular group.
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func fetchBannedMembers(for group: CometChatPro.Group){
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
        bannedMemberRequest = BannedGroupMembersRequest.BannedGroupMembersRequestBuilder(guid: currentGroup?.guid ?? "").set(limit: 100).build()
        bannedMemberRequest?.fetchNext(onSuccess: { (groupMembers) in
            self.bannedMembers = groupMembers
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
                self.tableView.tableFooterView?.isHidden = true}
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        })
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatBannedMembers: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of admins.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifies number of rows in CometChatAddModerators
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannedMembers.count
    }
    
    /// This method specifies the height for row in CometChatAddModerators
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// This method specifies height for section in CometChatAddModerators
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 0
    }
    
    
    /// This method specifies the view for admin  in CometChatAddModerators
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let  member =  bannedMembers[safe:indexPath.row]
        let membersCell = tableView.dequeueReusableCell(withIdentifier: "CometChatMembersItem", for: indexPath) as! CometChatMembersItem
        membersCell.member = member
        return membersCell
    }
    
    
    /// This method triggers the `UIMenu` when user holds on TableView cell.
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    ///   - point: A structure that contains a point in a two-dimensional coordinate system.
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            
            let unbanMember = UIAction(title: "UNBAN_MEMBER".localized(), image: UIImage(systemName: "person.crop.circle"), attributes: .destructive) { action in
                if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatMembersItem {
                    if let member = selectedCell.member, let uid = member.uid, let guid = self.currentGroup?.guid {
                        
                        CometChat.unbanGroupMember(UID: uid, GUID: guid, onSuccess: { (sucess) in
                            DispatchQueue.main.async {
                            self.fetchBannedMembers(for: self.currentGroup!)
                           
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: nil)
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    CometChatSnackBoard.showErrorMessage(for: error)
                                }
                            }
                        }
                    }
                }
            }
            return UIMenu(title:"Are you sure want to unban member?", children: [unbanMember])
        })
    }
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

                
                if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatMembersItem {
                    if let member = selectedCell.member, let uid = member.uid, let guid = self.currentGroup?.guid {
                        let alert = UIAlertController(title: "Unban Member", message: "Are you sure want to unban member?", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { action in
                            
                            CometChat.unbanGroupMember(UID: uid, GUID: guid, onSuccess: { (sucess) in
                                DispatchQueue.main.async {
                                self.fetchBannedMembers(for: self.currentGroup!)
                               
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: nil)
                                }
                            }) { (error) in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        CometChatSnackBoard.showErrorMessage(for: error)
                                    }
                                }
                            }
                
                        }))
                        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { action in
                        }))
                        alert.view.tintColor = UIKitSettings.primaryColor
                        self.present(alert, animated: true)
                    }
                }
            
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatGroupDelegate Delegate

extension CometChatBannedMembers: CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: CometChatPro.User, joinedGroup: CometChatPro.Group) {
        if let group = currentGroup {
            if group == joinedGroup {
                self.fetchBannedMembers(for: joinedGroup)
            }
        }
    }
    
    /**
     This method triggers when someone lefts group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - leftUser: Specifies `User` Object
     - leftGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: CometChatPro.User, leftGroup: CometChatPro.Group) {
        if let group = currentGroup {
            if group == leftGroup {
                fetchBannedMembers(for: group)
            }
        }
    }
    
    /**
     This method triggers when someone kicked from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - kickedUser: Specifies `User` Object
     - kickedBy: Specifies `User` Object
     - kickedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: CometChatPro.User, kickedBy: CometChatPro.User, kickedFrom: CometChatPro.Group) {
        if let group = currentGroup {
            if group == kickedFrom {
                fetchBannedMembers(for: group)
            }
        }
    }
    
    /**
     This method triggers when someone banned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - bannedUser: Specifies `User` Object
     - bannedBy: Specifies `User` Object
     - bannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: CometChatPro.User, bannedBy: CometChatPro.User, bannedFrom: CometChatPro.Group) {
        if let group = currentGroup {
            if group == bannedFrom {
                fetchBannedMembers(for: group)
            }
        }
    }
    
    /**
     This method triggers when someone unbanned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - unbannedUser: Specifies `User` Object
     - unbannedBy: Specifies `User` Object
     - unbannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: CometChatPro.User, unbannedBy: CometChatPro.User, unbannedFrom: CometChatPro.Group) {
        if let group = currentGroup {
            if group == unbannedFrom {
                fetchBannedMembers(for: group)
            }
        }
    }
    
    /**
     This method triggers when someone's scope changed  in the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - scopeChangeduser: Specifies `User` Object
     - scopeChangedBy: Specifies `User` Object
     - scopeChangedTo: Specifies `User` Object
     - scopeChangedFrom:  Specifies  description for scope changed
     - group: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: CometChatPro.User, scopeChangedBy: CometChatPro.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatPro.Group) {
        if let group = currentGroup {
            if group == group {
                fetchBannedMembers(for: group)
            }
        }
    }
    
    /**
     This method triggers when someone added in  the  group.
     - Parameters:
     - action:  Spcifies `ActionMessage` Object
     - addedBy: Specifies `User` Object
     - addedUser: Specifies `User` Object
     - addedTo: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: CometChatPro.User, addedUser: CometChatPro.User, addedTo: CometChatPro.Group) {
        if let group = currentGroup {
            if group == group {
                fetchBannedMembers(for: group)
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
