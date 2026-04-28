import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FirmDepositsController } from './firm-deposits.controller';
import { FirmDepositsService } from './firm-deposits.service';
import { FirmDeposit } from './firm-deposit.entity';

@Module({
  imports: [TypeOrmModule.forFeature([FirmDeposit])],
  controllers: [FirmDepositsController],
  providers: [FirmDepositsService],
  exports: [FirmDepositsService],
})
export class FirmDepositsModule {}
