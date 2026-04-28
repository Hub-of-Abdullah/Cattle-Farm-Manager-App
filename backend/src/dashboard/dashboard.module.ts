import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';
import { Owner } from '../owners/owner.entity';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';
import { Sale } from '../sales/sale.entity';
import { FirmDeposit } from '../firm-deposits/firm-deposit.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Owner, Cattle, Expense, Sale, FirmDeposit])],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
