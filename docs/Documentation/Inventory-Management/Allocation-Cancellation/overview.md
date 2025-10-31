# Allocation Cancellation Overview

## Introduction

The Allocation Cancellation feature in Business Central enables users to cancel inventory allocations (reservations) that have been made against sales orders and purchase orders. When inventory is reserved for a specific order line, it prevents that inventory from being allocated to other orders. This feature provides a controlled mechanism to release those reservations when business requirements change.

## Business Value

### Why Allocation Cancellation Matters

In dynamic business environments, circumstances often change after inventory has been allocated to specific orders:

- **Customer order changes**: A customer may modify their order quantity, delivery date, or cancel the order entirely
- **Inventory reallocation**: Higher-priority orders may require inventory that's currently reserved elsewhere
- **Supply chain disruptions**: Delays or shortages may require reallocating inventory to different customers
- **Production planning changes**: Manufacturing priorities may shift, requiring reallocation of component inventory
- **Order consolidation**: Multiple small orders may be combined into a single shipment
- **Expedited orders**: Rush orders may need inventory currently allocated to standard orders

Without a proper cancellation mechanism, businesses would need to manually adjust or delete entire order lines to free up inventory, which can lead to:
- Lost order history and audit trail
- Disrupted warehouse operations
- Incomplete financial records
- Difficulty tracking allocation changes over time

### Key Benefits

1. **Preserve Order History**: Cancel allocations without deleting order lines, maintaining complete transaction history
2. **Full Audit Trail**: Every cancellation is logged with date, time, user, reason code, and optional comments
3. **Inventory Flexibility**: Quickly release reserved inventory for reallocation to other orders
4. **Operational Efficiency**: Streamline the process of managing changing customer demands
5. **Compliance Support**: Maintain detailed records of all allocation changes for audit and compliance purposes
6. **Selective Cancellation**: Cancel allocations for specific order lines while leaving others intact

## High-Level Capabilities

The Allocation Cancellation feature provides the following capabilities:

### Sales Order Allocation Cancellation

- Cancel inventory allocations on one or multiple sales order lines simultaneously
- Automatic validation ensures only eligible lines can be cancelled
- Prevention of cancellation for lines that have been partially or fully shipped
- Prevention of cancellation for lines with active warehouse shipments
- Status tracking shows which lines have cancelled allocations

### Purchase Order Allocation Cancellation

- Cancel inventory allocations on one or multiple purchase order lines simultaneously
- Automatic validation ensures only eligible lines can be cancelled
- Prevention of cancellation for lines that have been partially or fully received
- Prevention of cancellation for lines with active warehouse receipts
- Status tracking shows which lines have cancelled allocations

### Comprehensive History Tracking

- Complete audit trail of all cancellations stored in dedicated history table
- Records include document details, item information, quantities, dates, times, and user information
- Mandatory reason codes ensure business justification is documented
- Optional comments field for additional context
- Direct navigation from history records back to source documents
- Export capabilities for external reporting and analysis

### Integration with Standard Processes

- Seamless integration with Business Central's reservation system
- Cancelled reservations are marked but not deleted, maintaining referential integrity
- Quantities on cancelled reservation entries are set to zero
- Original reservation entries remain linked to cancellation history
- No disruption to standard sales and purchase posting processes

## Feature Scope

### Supported Document Types

**Sales Documents:**
- Sales Orders (document type: Order)
- Sales Quotes (document type: Quote) - when reservations exist

**Purchase Documents:**
- Purchase Orders (document type: Order)
- Purchase Quotes (document type: Quote) - when reservations exist

**Not Supported:**
- Sales Return Orders
- Sales Credit Memos
- Purchase Return Orders
- Purchase Credit Memos

### Eligibility Requirements

Allocations can only be cancelled when ALL of the following conditions are met:

**For Sales Orders:**
1. Document status must be "Open" (not Released or Pending)
2. Line must have active reservations (reservation status other than "Prospect")
3. Line must not have any shipped quantity
4. Line must not have an existing warehouse shipment
5. Allocation status must not already be "Cancelled"

**For Purchase Orders:**
1. Document status must be "Open" (not Released or Pending)
2. Line must have active reservations (reservation status other than "Prospect")
3. Line must not have any received quantity
4. Line must not have an existing warehouse receipt
5. Allocation status must not already be "Cancelled"

## Who Should Use This Feature

### Primary Users

**Inventory Managers**: Responsible for optimizing inventory allocation across multiple orders to meet business priorities.

**Sales Order Processors**: Need to adjust allocations when customers change orders or when expedited orders require inventory reallocation.

**Purchasing Coordinators**: Manage incoming purchase order allocations and reallocate based on changing manufacturing or sales requirements.

**Warehouse Managers**: Coordinate with sales and purchasing teams to ensure inventory allocations align with shipping and receiving schedules.

### Required Permissions

Users must have the following permissions to use allocation cancellation features:

- **Read/Modify** access to Sales Line or Purchase Line tables
- **Read/Insert/Modify/Delete** access to Reservation Entry table
- **Read/Insert** access to VT Allocation Cancellation History table
- Access to Reason Codes for selection during cancellation process

Note: The "Cancel Allocation" action button is only enabled when the document is in "Open" status, providing built-in permission controls.

## Related Business Central Concepts

Understanding these standard Business Central concepts will help you use the Allocation Cancellation feature effectively:

**Reservations**: Business Central's native mechanism for allocating specific inventory to specific demand or supply. Reservations can be automatic or manual, and they link supply entries (like item ledger entries) to demand entries (like sales order lines).

**Reservation Status**: Indicates the type of reservation:
- **Surplus**: The reservation entry represents supply that is not reserved
- **Reservation**: The reservation entry represents a firm reservation link between supply and demand
- **Tracking**: The reservation entry represents item tracking information
- **Prospect**: The reservation entry represents a tentative reservation that is not yet confirmed

**Item Tracking**: The process of tracking items by serial number, lot number, or other identifying information. Reservations often involve item tracking assignments.

**Warehouse Management**: When warehouse management features are active, shipments and receipts must be processed through warehouse documents. Active warehouse documents prevent allocation cancellation.

## Next Steps

- **[Getting Started](getting-started.md)**: Learn how to access the allocation cancellation features
- **[Cancel Sales Order Allocations](cancel-sales-order-allocation.md)**: Step-by-step guide for cancelling sales order allocations
- **[Cancel Purchase Order Allocations](cancel-purchase-order-allocation.md)**: Step-by-step guide for cancelling purchase order allocations
- **[View Cancellation History](view-cancellation-history.md)**: Learn how to review and analyze cancellation history
- **[Field Reference](field-reference.md)**: Complete reference of all fields and their purposes
- **[Troubleshooting](troubleshooting.md)**: Solutions to common issues and error messages
