import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Sale } from './sale.entity';
import { Cattle } from '../cattle/cattle.entity';
import { FirmDeposit } from '../firm-deposits/firm-deposit.entity';
import { CreateSaleDto } from './dto/create-sale.dto';

@Injectable()
export class SalesService {
  constructor(
    @InjectRepository(Sale) private saleRepo: Repository<Sale>,
    @InjectRepository(Cattle) private cattleRepo: Repository<Cattle>,
    @InjectRepository(FirmDeposit) private depositRepo: Repository<FirmDeposit>,
  ) {}

  findAll(): Promise<Sale[]> {
    return this.saleRepo.find({ relations: ['cattle'], order: { saleDate: 'DESC' } });
  }

  async create(dto: CreateSaleDto): Promise<{ sale: Sale; firmDeposit?: FirmDeposit }> {
    const cattle = await this.cattleRepo.findOneBy({ id: dto.cattleId });
    if (!cattle) throw new NotFoundException(`Cattle with id ${dto.cattleId} not found`);
    if (cattle.isSold) throw new ConflictException('This cattle is already sold');

    const sale = await this.saleRepo.save(
      this.saleRepo.create({
        cattleId: dto.cattleId,
        saleDate: dto.saleDate,
        salePrice: dto.salePrice,
        buyerName: dto.buyerName,
      }),
    );

    await this.cattleRepo.update(dto.cattleId, { isSold: true });

    let firmDeposit: FirmDeposit | undefined;
    if (dto.addToFirmAccount) {
      firmDeposit = await this.depositRepo.save(
        this.depositRepo.create({
          amount: dto.firmAccountAmount ?? dto.salePrice,
          date: dto.saleDate,
          note: `Sale: ${cattle.cattleUniqueId}`,
        }),
      );
    }

    return { sale, firmDeposit };
  }

  async remove(id: number): Promise<void> {
    const sale = await this.saleRepo.findOne({ where: { id }, relations: ['cattle'] });
    if (!sale) throw new NotFoundException(`Sale with id ${id} not found`);
    await this.cattleRepo.update(sale.cattleId, { isSold: false });
    await this.saleRepo.remove(sale);
  }

  findForCattle(cattleId: number): Promise<Sale | null> {
    return this.saleRepo.findOneBy({ cattleId });
  }
}
