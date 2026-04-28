import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FirmDeposit } from './firm-deposit.entity';
import { CreateFirmDepositDto } from './dto/create-firm-deposit.dto';

@Injectable()
export class FirmDepositsService {
  constructor(
    @InjectRepository(FirmDeposit) private repo: Repository<FirmDeposit>,
  ) {}

  findAll(): Promise<FirmDeposit[]> {
    return this.repo.find({ order: { date: 'DESC' } });
  }

  async create(dto: CreateFirmDepositDto): Promise<FirmDeposit> {
    return this.repo.save(this.repo.create(dto));
  }

  async remove(id: number): Promise<void> {
    const deposit = await this.repo.findOneBy({ id });
    if (!deposit) throw new NotFoundException(`Deposit with id ${id} not found`);
    await this.repo.remove(deposit);
  }

  async totalDeposits(): Promise<number> {
    const result = await this.repo
      .createQueryBuilder('d')
      .select('COALESCE(SUM(d.amount), 0)', 'total')
      .getRawOne();
    return parseFloat(result.total);
  }
}
