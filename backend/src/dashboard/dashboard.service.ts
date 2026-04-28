import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Owner } from '../owners/owner.entity';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';
import { Sale } from '../sales/sale.entity';
import { FirmDeposit } from '../firm-deposits/firm-deposit.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(Owner) private ownerRepo: Repository<Owner>,
    @InjectRepository(Cattle) private cattleRepo: Repository<Cattle>,
    @InjectRepository(Expense) private expenseRepo: Repository<Expense>,
    @InjectRepository(Sale) private saleRepo: Repository<Sale>,
    @InjectRepository(FirmDeposit) private depositRepo: Repository<FirmDeposit>,
  ) {}

  async getStats() {
    const [totalOwners, totalCattle, activeCattle, soldCattle] = await Promise.all([
      this.ownerRepo.count(),
      this.cattleRepo.count(),
      this.cattleRepo.count({ where: { isSold: false } }),
      this.cattleRepo.count({ where: { isSold: true } }),
    ]);

    const [revenueResult, expensesResult, purchasesResult, depositsResult] =
      await Promise.all([
        this.saleRepo
          .createQueryBuilder('s')
          .select('COALESCE(SUM(s.sale_price), 0)', 'total')
          .getRawOne(),
        this.expenseRepo
          .createQueryBuilder('e')
          .select('COALESCE(SUM(e.amount), 0)', 'total')
          .getRawOne(),
        this.cattleRepo
          .createQueryBuilder('c')
          .select('COALESCE(SUM(c.purchase_price), 0)', 'total')
          .getRawOne(),
        this.depositRepo
          .createQueryBuilder('d')
          .select('COALESCE(SUM(d.amount), 0)', 'total')
          .getRawOne(),
      ]);

    const totalRevenue = parseFloat(revenueResult.total);
    const totalExpenses = parseFloat(expensesResult.total);
    const totalPurchaseCost = parseFloat(purchasesResult.total);
    const totalDeposits = parseFloat(depositsResult.total);
    const firmBalance = totalRevenue + totalDeposits - totalPurchaseCost - totalExpenses;

    return {
      totalOwners,
      totalCattle,
      activeCattle,
      soldCattle,
      totalRevenue,
      totalExpenses,
      totalPurchaseCost,
      totalDeposits,
      firmBalance,
    };
  }
}
