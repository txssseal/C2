require 'csv'

class Cart < ActiveRecord::Base
  has_many :cart_items
  has_many :comments
  has_many :approvals
  has_one :approval_group

  def update_approval_status
    return update_attributes(status: 'rejected') if has_rejection?
    return update_attributes(status: 'approved') if all_approvals_received?
  end

  def has_rejection?
    approvals.map(&:status).include?('rejected')
  end

  def all_approvals_received?
    approvals.where(status: 'approved').count == approval_group.users.count
  end

  def create_items_csv
    csv_string = CSV.generate do |csv|
    csv << ["description","details","vendor","url","notes","part_number","quantity","unit price","price for quantity"]
    cart_items.each do |item|
        csv << [item.description,item.details,item.vendor,item.url,item.notes,item.part_number,item.quantity,item.price,item.quantity*item.price]
        end
    end
    return csv_string
  end

# Note: I think the model for this is a little wrong.  We need comments on the
# the cart, but in fact, we are operating on comments on approvals, which we don't model at present.
  def create_comments_csv
    csv_string = CSV.generate do |csv|
    csv << ["comment","created_at"]
    date_sorted_comments = comments.sort { |a,b| a.updated_at <=> b.updated_at }
    date_sorted_comments.each do |item|
        csv << [item.comment_text,item.updated_at]
        end
    end
    return csv_string
  end

  def create_approvals_csv
    csv_string = CSV.generate do |csv|
    csv << ["status","approver","created_at"]
    approvals.each do |approval|
        csv << [approval.status, approval.user.email_address,approval.updated_at]
        end
    end
    return csv_string
  end

  def self.initialize_cart_with_items(params)
    approval_group_name = params['approvalGroup']

    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']

    existing_pending_cart =  Cart.find_by(name: name, status: 'pending')

    if existing_pending_cart.blank?

      cart = Cart.new(name: name, status: 'pending', external_id: params['cartNumber'])

      #Copy existing approvals
      #REFACTOR: fix this if block mess and replace duplication in communicarts_controller.rb for creating approvals
      if last_rejected_cart = Cart.where(name: name, status: 'rejected').last
        approval_group = last_rejected_cart.approval_group
        approval_group.users.each do | user |
          cart.approvals << Approval.create!(user_id: user.id)
        end
      end


      if !approval_group_name.blank?
        cart.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
      else
        cart.approval_group = ApprovalGroup.create(
                                name: "approval-group-#{params['cartNumber']}"
                              )
      end

    else

      cart =existing_pending_cart
      cart.cart_items.destroy_all
      cart.approval_group = nil

      #REFACTOR: duplicate code
      if !approval_group_name.blank?
        cart.approval_group = ApprovalGroup.find_by_name(params['approvalGroup'])
      else
        cart.approval_group = ApprovalGroup.create(
                                name: "approval-group-#{params['cartNumber']}",
                                approvers_attributes: [
                                  { email_address: params['fromAddress'] }
                                ]
                              )
      end
    end

    cart.save


    #TODO: accepts_nested_attributes_for
    #TODO: save green, socio, and features information
    params['cartItems'].each do |cart_item_params|
      CartItem.create(
        :vendor => cart_item_params['vendor'],
        :description => cart_item_params['description'],
        :url => cart_item_params['url'],
        :notes => cart_item_params['notes'],
        :quantity => cart_item_params['qty'],
        :details => cart_item_params['details'],
        :part_number => cart_item_params['partNumber'],
        :price => cart_item_params['price'].gsub(/[\$\,]/,"").to_f,
        :cart_id => cart.id
      )
    end
    return cart
  end

end

# TODO: states: awaiting_approvals, approved, rejected
