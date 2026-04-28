import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OwnersController } from './owners.controller';
import { OwnersService } from './owners.service';
import { Owner } from './owner.entity';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';
import { Sale } from '../sales/sale.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Owner, Cattle, Expense, Sale])],
  controllers: [OwnersController],
  providers: [OwnersService],
  exports: [OwnersService],
})
export class OwnersModule {}
