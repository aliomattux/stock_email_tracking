from openerp.osv import osv, fields

class StockPicking(osv.osv):
    _inherit = 'stock.picking'

    def send_one_tracking_email(self, cr, uid, ids, context=None):
	picking = self.browse(cr, uid, ids[0])
	report_obj = self.pool.get('stock.email.report')
	return report_obj.render(cr, uid, [picking])
