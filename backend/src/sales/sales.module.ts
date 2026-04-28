import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SalesController } from './sales.controller';
import { SalesService } from './sales.service';
import { Sale } from './sale.entity';
import { Cattle } from '../cattle/cattle.entity';
import { FirmDeposit } from '../firm-deposits/firm-deposit.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Sale, Cattle, FirmDeposit])],
  controllers: [SalesController],
  providers: [SalesService],
  exports: [SalesService],
})
export class SalesModule {}
