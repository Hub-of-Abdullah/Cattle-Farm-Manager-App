import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Owner } from '../owners/owner.entity';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';
import { Sale } from '../sales/sale.entity';
import { FirmDeposit } from '../firm-deposits/firm-deposit.entity';
import { ExpenseCategory } from '../expenses/expense.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Owner) private ownerRepo: Repository<Owner>,
    @InjectRepository(Cattle) private cattleRepo: Repository<Cattle>,
    @InjectRepository(Expense) private expenseRepo: Repository<Expense>,
    @InjectRepository(Sale) private saleRepo: Repository<Sale>,
    @InjectRepository(FirmDeposit) private depositRepo: Repository<FirmDeposit>,
  ) {}

  async getSummary() {
    const [allCattle, soldCattle, sales, expenses, deposits] = await Promise.all([
      this.cattleRepo.find(),
      this.cattleRepo.find({ where: { isSold: true } }),
      this.saleRepo.find(),
      this.expenseRepo.find(),
      this.depositRepo.find(),
    ]);

    const totalRevenue = sales.reduce((s, x) => s + x.salePrice, 0);
    const totalExpenses = expenses.reduce((s, x) => s + x.amount, 0);
    const totalPurchaseCostSold = soldCattle.reduce((s, c) => s + c.purchasePrice, 0);
    const totalAllPurchases = allCattle.reduce((s, c) => s + c.purchasePrice, 0);
    const totalDeposits = deposits.reduce((s, d) => s + d.amount, 0);

    const expensesByCategory: Record<string, number> = {};
    for (const cat of Object.values(ExpenseCategory)) {
      expensesByCategory[cat] = expenses
        .filter((e) => e.category === cat)
        .reduce((s, e) => s + e.amount, 0);
    }

    return {
      overview: {
        totalCattle: allCattle.length,
        activeCattle: allCattle.filter((c) => !c.isSold).length,
        soldCattle: soldCattle.length,
      },
      financial: {
        totalRevenue,
        totalExpenses,
        totalPurchaseCostSold,
        profitLoss: totalRevenue - totalPurchaseCostSold,
      },
      firmAccount: {
        totalRevenue,
        totalDeposits,
        totalPurchaseCost: totalAllPurchases,
        totalExpenses,
        balance: totalRevenue + totalDeposits - totalAllPurchases - totalExpenses,
      },
      expensesByCategory,
    };
  }

  async getPerOwner() {
    const owners = await this.ownerRepo.find();
    const result = await Promise.all(
      owners.map(async (owner) => {
        const cattle = await this.cattleRepo.find({ where: { ownerId: owner.id } });
        const expenses = await this.expenseRepo.find({ where: { ownerId: owner.id } });
        const sold = cattle.filter((c) => c.isSold);
        const soldIds = sold.map((c) => c.id);

        let totalRevenue = 0;
        if (soldIds.length > 0) {
          const sales = await this.saleRepo
            .createQueryBuilder('s')
            .where('s.cattle_id IN (:...ids)', { ids: soldIds })
            .getMany();
          totalRevenue = sales.reduce((s, x) => s + x.salePrice, 0);
        }

        const totalPurchaseCost = cattle.reduce((s, c) => s + c.purchasePrice, 0);
        const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);

        return {
          owner: { id: owner.id, name: owner.name },
          totalCattle: cattle.length,
          activeCattle: cattle.filter((c) => !c.isSold).length,
          soldCattle: sold.length,
          totalPurchaseCost,
          totalExpenses,
          totalRevenue,
          balance: totalRevenue - totalPurchaseCost - totalExpenses,
        };
      }),
    );
    return result;
  }

  async getPerCattle() {
    const sold = await this.cattleRepo.find({ where: { isSold: true }, relations: ['sale'] });
    return sold.map((c) => ({
      cattle: { id: c.id, cattleUniqueId: c.cattleUniqueId, purchasePrice: c.purchasePrice },
      salePrice: c.sale?.salePrice ?? null,
      profitLoss: c.sale ? c.sale.salePrice - c.purchasePrice : null,
    }));
  }

  async getTransactions() {
    const [deposits, sales, expenses] = await Promise.all([
      this.depositRepo.find({ order: { date: 'DESC' } }),
      this.saleRepo.find({ relations: ['cattle'], order: { saleDate: 'DESC' } }),
      this.expenseRepo.find({ relations: ['owner'], order: { date: 'DESC' } }),
    ]);

    const txList = [
      ...deposits.map((d) => ({
        type: 'deposit',
        date: d.date,
        amount: d.amount,
        title: d.amount < 0 ? 'Subtract Money' : 'Add Money',
        subtitle: d.note ?? null,
        icon: d.amount < 0 ? 'remove_circle_outline' : 'add_circle_outline',
        deletable: true,
        id: d.id,
      })),
      ...sales.map((s) => ({
        type: 'sale',
        date: s.saleDate,
        amount: s.salePrice,
        title: `Sale: ${s.cattle?.cattleUniqueId ?? s.cattleId}`,
        subtitle: s.buyerName ? `Buyer: ${s.buyerName}` : null,
        icon: 'sell',
        deletable: false,
      })),
      ...expenses.map((e) => ({
        type: 'expense',
        date: e.date,
        amount: -e.amount,
        title: `Expense: ${e.customCategory ?? e.category}`,
        subtitle: e.owner?.name ?? null,
        icon: 'receipt_long',
        deletable: false,
      })),
    ].sort((a, b) => (a.date < b.date ? 1 : -1));

    return txList;
  }
}
